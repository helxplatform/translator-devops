# Jaeger v2 Helm Chart Deployment

This folder contains Helm values files to deploy [Jaeger v2](https://www.jaegertracing.io/) (all-in-one) using Elasticsearch as the backend persistent storage for distributed tracing in a Kubernetes cluster.

## Overview

- **Jaeger chart version**: `4.7.0`
- **Jaeger app version**: `2.17.0`
- **Storage backend**: Elasticsearch (persistent single-node for now, but can be enhanced with more shards/nodes for scalability as needed)
- **Architecture**: All-in-one (Collector + Query + UI in a single pod)
- **Trace ingestion**: OTLP gRPC (port 4317) and OTLP HTTP (port 4318)
- **UI access**: Via NGINX ingress with TLS (cert-manager + Let's Encrypt)

## Files

| File | Purpose |
|---|---|
| `elasticsearch-values.yaml` | Deploys a single-node Elasticsearch instance with persistent storage |
| `jaeger-values.yaml` | Deploys Jaeger v2 all-in-one connected to the Elasticsearch backend |

## Prerequisites

- Kubernetes cluster with `kubectl` and `helm` configured
- NGINX ingress controller deployed in the cluster
- `cert-manager` deployed with a `letsencrypt` ClusterIssuer
- A `StorageClass` available for PVC provisioning (`basic` storage class is used for ElasticSearch PVC)

## Deployment Steps

### Step 1 — Add Helm repositories

```bash
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo add elastic https://helm.elastic.co
helm repo update
```

### Step 2 — Deploy Elasticsearch

```bash
helm install elasticsearch elastic/elasticsearch \
  -n <your-namespace> \
  -f elasticsearch-values.yaml
```

Wait for Elasticsearch to be ready before proceeding:

```bash
kubectl -n <your-namespace> rollout status statefulset/elasticsearch-master --timeout=5m
```

### Step 3 — Retrieve the Elasticsearch password and create the Jaeger secret

The Elasticsearch chart auto-generates a password on install and stores it in a Kubernetes secret. Retrieve the password:

```bash
kubectl get secret -n <your-namespace> elasticsearch-master-credentials \
  -o jsonpath='{.data.password}' | base64 -d
```

Save this password — you will need it in Steps 4 and 5.

Verify Elasticsearch is healthy using the retrieved password: 

```bash kubectl exec -n  elasticsearch-master-0 -- \  curl -sk "https://localhost:9200/_cat/health?v" \  -u elastic:<retrieved_password>```

Create the Kubernetes secret that Jaeger will use to authenticate with Elasticsearch:

```bash
kubectl create secret generic jaeger-es-credentials \
  -n <your-namespace> \
  --from-literal=ES_PASSWORD=<retrieved_password>
```

### Step 4 — Create `jaeger-secret-values.yaml`

 Create a local file `jaeger-secret-values.yaml` as shown below with the Elasticsearch password. **Do not check this file into github.** 

```
# jaeger-secret-values.yaml — local only, never commit
userconfig:
  extensions:
    jaeger_storage:
      backends:
        some_storage:
          elasticsearch:
            auth:
              basic:
                username: "elastic"
                password: "retrieved_password"
```

Add it to `.gitignore` to make sure it is not checked into github.

### Step 5 — Update `jaeger-values.yaml`

Before deploying Jaeger, update `jaeger-values.yaml` as needed. Specifically:

- Update `hosts` and `tls` `hosts` and `secretName` for the Jaeger UI ingress to fit your deployment. Note that the TLS secret name typically matches the hostname, e.g. `jaeger.apps.your-org.com-tls` for `hosts` of `jaeger.apps.your-org.com`.
- As currently configured, a CronJob (`jaeger-es-index-cleaner`) runs nightly at 23:55 and deletes Elasticsearch indices older than 7 days. Adjust `esIndexCleaner.numberOfDays` in `jaeger-values.yaml` to change retention as needed.

### Step 6 — Deploy Jaeger

```bash
helm install jaeger jaegertracing/jaeger \
  --version 4.7.0 \
  -n <your-namespace> \
  -f jaeger-values.yaml \
  -f jaeger-secret-values.yaml
```

### Step 7 — Verify the deployment and access the Jaeger UI

```bash
# All pods should be Running
kubectl get pods -n <your-namespace> | grep -E "elasticsearch|jaeger"

# ES indices appear after first traces are ingested
kubectl exec -n <your-namespace> elasticsearch-master-0 -- \
  curl -sk "https://localhost:9200/_cat/indices?v" -u elastic:<retrieved_password> | grep jaeger
```

Access the Jaeger UI by going to `https://<your-hostname-set-up-in-ingress>` on your browser.

## Upgrading

To upgrade Jaeger after changing values:

```bash
helm upgrade jaeger jaegertracing/jaeger \
  --version 4.7.0 \
  -n <your-namespace> \
  -f jaeger-values.yaml \
  -f jaeger-secret-values.yaml
```

To upgrade Elasticsearch:

```bash
helm upgrade elasticsearch elastic/elasticsearch \
  -n <your-namespace> \
  -f elasticsearch-values.yaml
```

## Instrumenting Applications

Jaeger v2 receives traces via the OpenTelemetry Protocol (OTLP) and you can instrument your apps using the OpenTelemetry SDK  and point your OTLP exporter to `http://<jaeger-svc>:4317` (gRPC) or `:4318` (HTTP) if your apps and the jaeger service are deployed in the same namespace. 

For apps in a different namespace, use the full service DNS name such as `http://jaeger.<jaeger-namespace>.svc.cluster.local:4317` or just `http://jaeger.<jaeger-namespace>`. However, cross-namespace traffic may be subject to NetworkPolicy restrictions in the k8s cluster. If a NetworkPolicy exists on the jaeger namespace restricting ingress access from other namespaces, you'd need to add a rule allowing traffic from the app's namespace on port 4317 or 4318. 

## Future Scalability Considerations

The current deployment is a single-node all-in-one setup suitable for small to medium workloads. The following changes should be considered as trace volume grows:

### Elasticsearch scaling

- **Increase ES replicas**: Change `replicas: 1` to 3+ in `elasticsearch-values.yaml` and update `minimumMasterNodes` accordingly to fit your deployment. Update `replicas: 0` in the Jaeger index settings in `jaeger-values.yaml` to `replicas: 1` to enable shard replication.
- **Increase shard count**: Update `shards: 1` to a higher value (e.g. 3-5) in `jaeger-values.yaml` in the
  `userconfig.extensions.jaeger_storage.backends.some_storage.elasticsearch.indices`block to distribute index load across ES nodes.
- **Enable index rollover**: Replace date-based index rotation with ILM (Index Lifecycle Management) rollover policies for better control over index size. Jaeger supports `esRollover` via a separate CronJob — enable with `esRollover.enabled: true`.
- **Dedicated ES nodes**: Separate master, data, and coordinating ES nodes for large deployments using the Elastic Helm chart's `master`, `data`, and `coordinating` node group settings.

### Jaeger scaling

- **Separate Collector and Query**: For high trace volume, split the all-in-one deployment into separate Jaeger Collector and Jaeger Query deployments. The Collector can then be horizontally scaled (`replicas: N`) independently of the Query/UI component.
- **Increase batch processor settings**: Tune `processors.batch.send_batch_size` and `processors.batch.timeout` in `userconfig` to optimize throughput vs. latency.

### Archive storage

Jaeger supports a secondary long-term archive storage backend for traces you want to retain beyond the primary retention window. To enable:

1. Add a second ES backend (`archive_store`) to `jaeger_storage.backends` in `userconfig` pointing to a separate ES index prefix or cluster.
2. Enable archive in `jaeger_query`:
   ```yaml
   jaeger_query:
     storage:
       traces: some_storage
       traces_archive: archive_store
   ```
3. Users can then click "Archive Trace" in the Jaeger UI on any individual trace to preserve it permanently beyond the 7-day cleanup window.

### Authentication for Jaeger UI

Jaeger UI has no built-in authentication. For production deployments with broader access, add authentication at the ingress layer:

- **Basic auth**: via NGINX ingress `auth-type: basic` annotation
- **OAuth2/SSO**: Deploy an [OAuth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/) sidecar in front of Jaeger and configure your org's SSO provider
