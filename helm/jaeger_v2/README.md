# Jaeger v2 Helm Chart Deployment

This folder contains Helm values files to deploy [Jaeger v2](https://www.jaegertracing.io/) (all-in-one) using Elasticsearch as the backend persistent storage for distributed tracing in a Kubernetes cluster.

## Overview

- **Jaeger chart version**: `4.16.1`
- **Jaeger app version**: `2.22.0`
- **Elasticsearch chart version**: `8.5.1` (latest published `elastic/elasticsearch` chart)
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

### Step 2 — Create the Elasticsearch credentials secret

Elasticsearch, Jaeger, and the index cleaner CronJob all read the `elastic` user's password from a single secret, `jaeger-es-credentials`. Create it once with a random password; nobody needs to see or type it:

```bash
kubectl create secret generic jaeger-es-credentials \
  -n <your-namespace> \
  --from-literal=password="$(openssl rand -base64 24)"
```

The secret is created by hand rather than by the Elasticsearch chart because the chart regenerates its password on every `helm upgrade`, which would break Jaeger's access. Don't delete this secret.

### Step 3 — Deploy Elasticsearch

```bash
helm install jaeger-es elastic/elasticsearch \
  --version 8.5.1 \
  -n <your-namespace> \
  -f elasticsearch-values.yaml
```

Wait for Elasticsearch to be ready, then check its health. The password is read from the pod's environment, so it never leaves the cluster:

```bash
kubectl -n <your-namespace> rollout status statefulset/jaeger-es-master --timeout=5m

kubectl exec -n <your-namespace> jaeger-es-master-0 -- \
  sh -c 'curl -sk -u "elastic:$ELASTIC_PASSWORD" "https://localhost:9200/_cat/health?v"'
```

### Step 4 — Update `jaeger-values.yaml`

Before deploying Jaeger, update `jaeger-values.yaml` as needed. Specifically:

- Update `hosts` and `tls` `hosts` and `secretName` for the Jaeger UI ingress to fit your deployment. Note that the TLS secret name typically matches the hostname, e.g. `jaeger.apps.your-org.com-tls` for `hosts` of `jaeger.apps.your-org.com`.
- As currently configured, a CronJob (`jaeger-es-index-cleaner`) runs nightly at 23:55 and deletes Elasticsearch indices older than 14 days. Adjust `esIndexCleaner.numberOfDays` in `jaeger-values.yaml` to change retention as needed.

### Step 5 — Deploy Jaeger

```bash
helm install jaeger jaegertracing/jaeger \
  --version 4.16.1 \
  -n <your-namespace> \
  -f jaeger-values.yaml
```

### Step 6 — Verify the deployment and access the Jaeger UI

```bash
# All pods should be Running
kubectl get pods -n <your-namespace> | grep jaeger

# ES indices appear after first traces are ingested
kubectl exec -n <your-namespace> jaeger-es-master-0 -- \
  sh -c 'curl -sk -u "elastic:$ELASTIC_PASSWORD" "https://localhost:9200/_cat/indices?v"' | grep jaeger
```

Access the Jaeger UI by going to `https://<your-hostname-set-up-in-ingress>` on your browser.

## Upgrading

To upgrade Jaeger after changing values:

```bash
helm upgrade jaeger jaegertracing/jaeger \
  --version 4.16.1 \
  -n <your-namespace> \
  -f jaeger-values.yaml
```

To upgrade Elasticsearch:

```bash
helm upgrade jaeger-es elastic/elasticsearch \
  --version 8.5.1 \
  -n <your-namespace> \
  -f elasticsearch-values.yaml
```

## Instrumenting Applications

Jaeger v2 receives traces via the OpenTelemetry Protocol (OTLP) and you can instrument your apps using the OpenTelemetry SDK  and point your OTLP exporter to `http://<jaeger-svc>:4317` (gRPC) or `:4318` (HTTP) if your apps and the jaeger service are deployed in the same namespace. 

For apps in a different namespace, use the full service DNS name such as `http://jaeger.<jaeger-namespace>.svc.cluster.local:4317` or just `http://jaeger.<jaeger-namespace>`. However, cross-namespace traffic may be subject to NetworkPolicy restrictions in the k8s cluster. If a NetworkPolicy exists on the jaeger namespace restricting ingress access from other namespaces, you'd need to add a rule allowing traffic from the app's namespace on port 4317 or 4318. 

Apps configured for the v1 deployment send OTLP to `http://jaeger-otel-collector[.<namespace>]:4317`. To avoid changing every app at once, `jaeger-values.yaml` creates a transitional `jaeger-otel-collector` Service (via `extraObjects`) that exposes only the OTLP ports (4317/4318) of the v2 all-in-one pod. When we migrate them all to point to `http://jaeger` we can remove the alias.

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
3. Users can then click "Archive Trace" in the Jaeger UI on any individual trace to preserve it permanently beyond the 14-day cleanup window.

### Authentication for Jaeger UI

Jaeger UI has no built-in authentication. For production deployments with broader access, add authentication at the ingress layer:

- **Basic auth**: via NGINX ingress `auth-type: basic` annotation
- **OAuth2/SSO**: Deploy an [OAuth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/) sidecar in front of Jaeger and configure your org's SSO provider
