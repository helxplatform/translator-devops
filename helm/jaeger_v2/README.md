# Jaeger v2

Helm chart for [Jaeger v2](https://www.jaegertracing.io/) (all-in-one) with a single-node [OpenSearch](https://opensearch.org/) backend. It wraps the upstream Jaeger and OpenSearch charts, and [Helmfile](https://helmfile.readthedocs.io/) deploys it to each environment.

- **Versions**: Jaeger chart `4.16.1` (Jaeger `2.22.0`), OpenSearch chart `3.9.0` (OpenSearch `3.9.0`)
- **Trace ingestion**: OTLP gRPC on port 4317, OTLP HTTP on port 4318
- **Environments**: `dev` (RENCI), `ci`, `test`, `prod` (NCATS ITRB)

## Files

| File | Purpose |
|---|---|
| `Chart.yaml`, `Chart.lock`, `charts/*.tgz` | Pinned upstream charts, committed so deploys don't need to fetch them |
| `values.yaml` | Settings shared by every environment |
| `values-<environment>.yaml` | Per-environment settings (ingress, storage class) |
| `templates/itrb-ingress.yaml` | ALB ingress for the NCATS environments |
| `templates/opensearch-networkpolicy.yaml` | Lets only the Jaeger pod and the index cleaner reach OpenSearch |
| `helmfile.yaml.gotmpl` | Maps each environment to its namespace and values file |

## Prerequisites

- `kubectl`, `helm`, [`helmfile`](https://helmfile.readthedocs.io/en/latest/#installation), and the [`helm-diff`](https://github.com/databus23/helm-diff) plugin: `helm plugin install https://github.com/databus23/helm-diff` (add `--verify=false` on Helm 4)
- An ingress controller: NGINX with a cert-manager `letsencrypt` ClusterIssuer (RENCI), or the AWS Load Balancer Controller (NCATS)
- A StorageClass for the OpenSearch volume (`basic` at RENCI, the cluster default elsewhere)

## Deploy

### 1. Create the credentials secret (once per environment)

```bash
kubectl create secret generic jaeger-opensearch-credentials -n <namespace> \
  --from-literal=password="$(openssl rand -base64 24)-Aa1"
```

This is the password for OpenSearch's `admin` user, used by OpenSearch, Jaeger and the index cleaner. The `-Aa1` suffix meets OpenSearch's password strength rules. OpenSearch only reads it on first start, so don't change or delete the secret afterwards.

### 2. Deploy

```bash
helmfile -e <environment> diff    # preview changes
helmfile -e <environment> apply   # deploy
```

Jaeger may restart a few times on the first install while OpenSearch starts.

### 3. Verify

```bash
# All pods should be Running
kubectl get pods -n <namespace> | grep jaeger

# OpenSearch health
kubectl exec -n <namespace> jaeger-opensearch-master-0 -- \
  sh -c 'curl -sk -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" "https://localhost:9200/_cat/health?v"'

# Jaeger indices (appear once traces arrive)
kubectl exec -n <namespace> jaeger-opensearch-master-0 -- \
  sh -c 'curl -sk -u "admin:$OPENSEARCH_INITIAL_ADMIN_PASSWORD" "https://localhost:9200/_cat/indices?v"' | grep jaeger

# Run the index cleaner once; it should complete without errors
kubectl create job --from=cronjob/jaeger-es-index-cleaner cleaner-test -n <namespace>
kubectl wait --for=condition=complete job/cleaner-test -n <namespace> --timeout=2m
kubectl logs job/cleaner-test -n <namespace>
kubectl delete job cleaner-test -n <namespace>
```

Then open the Jaeger UI at the environment's ingress host.

## Making changes

- **All environments**: edit `values.yaml`. **One environment**: edit `values-<environment>.yaml`. Then run `helmfile -e <environment> diff` and `apply`.
- **New environment**: add `values-<name>.yaml` and an entry under `environments:` in `helmfile.yaml.gotmpl`.
- **Upgrade an upstream chart**: change its version in `Chart.yaml` and run `helm dependency update`. Update `appVersion` and bump `version`, then commit `Chart.yaml`, `Chart.lock` and `charts/*.tgz`. Image tags follow the upstream charts.
- **Retention**: `jaeger.esIndexCleaner.numberOfDays` (currently 10 days). The cleaner runs nightly at 23:55, cluster time (usually UTC).

## Sending traces

- **Same namespace**: `http://jaeger:4317` (gRPC) or `http://jaeger:4318` (HTTP).
- **Other namespaces**: `http://jaeger.<namespace>:4317`. Any NetworkPolicy on the Jaeger namespace must allow it.
- **Apps still set up for v1** can keep sending to `jaeger-otel-collector:4317`. This is a transitional alias Service (`jaeger.extraObjects` in `values.yaml`); remove it once every app uses `jaeger`.

## Scaling later

- **More OpenSearch nodes**: set `opensearch.singleNode: false` and `opensearch.replicas` to 3+. Raise the index `replicas` (and `shards` as needed) in `jaeger.userconfig`, and allow port 9300 between OpenSearch pods in the NetworkPolicy.
- **Size-based index rollover** instead of daily indices: switch each index's `rotation` from `periodic` to `manual_rollover` (with `jaeger.esRollover.enabled: true`) or `auto_rollover` (an OpenSearch ISM policy). Also add `rollover: true` to the cleaner's `cmdlineParams`. Don't use the deprecated `use_aliases` / `use_ilm`; Jaeger 2.22 rejects them.
- **Higher trace volume**: split Jaeger into separate collector and query deployments, and tune `processors.batch` in `jaeger.userconfig`.
- **Archive storage**: add a second OpenSearch backend with its own `index_prefix`, and set it as `jaeger_query.storage.traces_archive`. The UI's "Archive Trace" then keeps traces past retention.
- **UI authentication**: the Jaeger UI has none. Add basic auth or [OAuth2 Proxy](https://oauth2-proxy.github.io/oauth2-proxy/) at the ingress.