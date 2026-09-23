Answer Coalesce helm Chart
---
> [Source code for Answer Coelesce](https://github.com/ranking-agent/AnswerCoalesce)
>
> [Docker Image](https://hub.docker.com/repository/docker/renciorg/ac)


This service accepts a translator reasoner standard message containing answers and returns the same format with 
answers that have been coalesced. A live version of the API can be found [here](https://answercoalesce.renci.org/docs).


### Data

Answer Coalesce reads its graph from a DuckDB database file. The web server runs
as a StatefulSet; an init container downloads the dump named by `ac.duckdb.url`
onto a per-replica `ReadWriteOnce` volume, and the app is pointed at it with
`AC_DUCKDB_PATH=/data/answer-coalesce.duckdb`.

The download is skipped when the file is already on the volume and its size
matches the one the server advertises, so pod restarts don't re-fetch several
GB. To move to a newer dump, change `ac.duckdb.url` (or publish a
different-sized file at the same URL) and restart the pod — the init container
downloads alongside the current database and swaps it in when the download
finishes, which is why `ac.duckdb.storage.size` should be about twice the dump
size.

### Parameters 

Installation can be configured with the following parameters.


| Parameter | Description | Default |
| --------- | ----        | ----    | 
| `replicaCount` |  Web server replica count | `1` 
| `ac.image.repository` |  Web server docker image | `ghcr.io/ranking-agent/answercoalesce`
| `ac.image.tag` |  Web server docker tag | `latest`
| `ac.service.type` |  Web server kubernetes service type | `ClusterIP`
| `ac.service.port` | Web server kubernetes service port  | `80`
| `ac.containerPort` |  Web server port | `8080`
| `ac.workers` | uvicorn worker processes. DuckDB caches one database instance per process, so each worker has a single shared buffer pool and the `AC_DUCKDB_QUERY_*` settings apply per worker — every memory and spill budget is `workers` x the per-process figure. | `2`
| `ac.resources` | Web container resource requests / limits | see `values.yaml`
| `ac.limitConcurrency` | Optional uvicorn `--limit-concurrency`. Past this many connections *or* tasks a worker answers 503 and closes the connection — a backstop against OOM, not a queue. Counts idle keep-alive connections, applies per worker, and 503s `/docs` and probes on the same rule. Omitted when unset. | `nil`
| `ac.tmpSizeLimit` | Size of the `/tmp` scratch volume DuckDB spills to. Must stay above `ac.workers` x `AC_DUCKDB_QUERY_MAX_TEMP_DIRECTORY_SIZE` (8GB), or the pod is evicted for overrunning the volume before DuckDB's cap applies. | `20Gi`
| `ac.env` | Extra environment variables for the web container. The app's defaults already match upstream's recommended runtime settings (`AC_DUCKDB_QUERY_MEMORY_LIMIT=1GB`, `AC_DUCKDB_QUERY_MAX_TEMP_DIRECTORY_SIZE=8GB`, `AC_DUCKDB_QUERY_THREADS=2`) — all per worker process — so set these only to deviate. `NODE_NORMALIZER_URL` is also read here. | `{}`
| `ac.duckdb.url` | DuckDB dump downloaded by the init container. Required. | RENCI hierarchy-pruned dump
| `ac.duckdb.storage.size` | Size of the data volume. Should be ~2x the dump size to leave room for a replacement download. | `20Gi`
| `ac.duckdb.storage.class` | Storage class for the data volume; empty uses the cluster default. | `nil`
| `ac.duckdb.initresources` | Download init container resource requests / limits | see `values.yaml`
| `busybox.image.repository` | Image used by the download init container; needs `curl` | `curlimages/curl`
| `busybox.image.tag` | Tag of the download image | `8.20.0`
| `podSecurityContext` | Pod security context; `fsGroup` lets the non-root init container write to the data volume | `fsGroup: 1000`
| `app.nodeSelector` / `app.affinity` / `app.tolerations` | Scheduling for the web pod | `{}`
| `nameOverride` | Release name override  | `nil`
| `fullnameOverride` | Release full name override  | `nil`
| `ingress.enabled` | Enables Ingress  | `True`
| `ingress.host` |  Ingress DNS host name  | ``
| `ingress.class` | Ingress class  | ``


### Installing


To deploy Answer coalesce : 
```shell script
<.../helm/answer-coalesce>$ helm -n <your-namespace> install my-release .
```

### Uninstalling
```shell script
<.../helm/answer-coalesce>$ helm uninstall myrelease
```

### Upgrading
```shell script
<.../helm/answer-coalesce>$ helm upgrade --set app.port=80 myrelease .
```

###Other deployment commands
To render your chart without deploying:
 
```shell script
$ helm template --debug -f <values_file> myrelease .
```
​
To dry run your chart install: 
```console
$ helm install -f <values_file> --dry-run --debug myrelease .
```


 