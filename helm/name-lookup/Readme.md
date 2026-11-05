# NameRes (name-lookup) Helm chart

This chart deploys [NameRes](https://github.com/NCATSTranslator/NameResolution)
(Name Resolution / Name Lookup) on Kubernetes:

- a single-pod Apache Solr StatefulSet that serves a prebuilt `name_lookup` core,
- the NameRes web API (image: `ghcr.io/ncatstranslator/nameresolution`),
- an optional ingress, and
- a one-shot Job that deletes blocklisted CURIEs from the index.

The Solr index is **not** built by this chart. It is downloaded as a ready-to-serve
Solr backup (`snapshot.backup.tar.gz`) from the URL in `dataUrl`. How to build that
backup from Babel synonym files is documented in the NameRes repository:
https://github.com/NCATSTranslator/NameResolution/blob/main/data-loading/README.md

A running instance: https://name-resolution-sri.renci.org/docs

## Prerequisites

- Kubernetes and Helm 3.
- A node that can hold the Solr pod. Defaults are 64Gi memory (requests == limits) and a
  400Gi persistent volume; the comments in `values.yaml` explain how these were sized and
  what to change if queries are slow. Check `kubectl describe node` before installing.
- A Solr backup tarball on a URL the cluster can reach. The serving Solr must be the same
  minor version or newer than the Solr that built it; this chart tracks `solr:9.10`, which
  matches the current data-loading image.
- To use the RENCI or ITRB values files in this directory, git-crypt unlocked (see the
  repository README). The files you need are listed below.

## Values files in this directory

Values files are layered with repeated `-f` flags; later files override earlier ones.

| File | Use |
| --- | --- |
| `values.yaml` | Defaults. Heavily commented: read it before changing memory, heap, GC or storage. |
| `values-populated.yaml` | The blocklist URL and the GitHub token that reads it. Encrypted. Every environment, RENCI and ITRB, layers this file: it is the only place the blocklist is configured, so all instances read the same list and share one token rotation. |
| `renci-dev-values-populated.yaml` | RENCI Dev (name-resolution-sri.renci.org). Encrypted. |
| `renci-exp-values-populated.yaml` | RENCI Exp (name-resolution-exp.apps.renci.org). Encrypted. |
| `robokop-values-populated.yaml` | ROBOKOP instance: layer it on top of the RENCI Exp file (see the comment at the top of the file). |
| `ncats-dev-values.yaml`, `ncats-test-values.yaml`, `ncats-prod-values.yaml` | ITRB environments. Encrypted. The ITRB pipeline substitutes `DOCKER_IMAGE_VERSION` from `ncats-images-meta.yaml` (see `../../ITRB-Pattern.md`). |
| `ncats-images-meta.yaml` | Image names and versions for ITRB. Bump it with every release. |

## Values you will actually set

Everything else has a sensible default and a comment in `values.yaml`.

| Value | What it does |
| --- | --- |
| `dataUrl` | URL of `snapshot.backup.tar.gz`. Set: the Solr pod downloads and extracts it before starting. Empty: the existing index is left alone. See "Installing" below. |
| `data.babelVersion`, `data.babelVersionURL`, `data.biolinkModelTag` | Reported by `/status`. Keep in step with `dataUrl`. |
| `webServer.image.tag` | NameRes version, e.g. `v1.7.1`. |
| `webServer.serverHostName` | Public URL of this instance, e.g. `https://name-resolution-sri.renci.org`. Used by the OpenAPI docs. |
| `ingress.enabled`, `ingress.host`, `ingress.class`, `ingress.tls.enabled`, `ingress.annotations` | Ingress. Off by default. |
| `blocklist.url`, `blocklist.secrets.github_personal_access_token` | Blocklist. See below. |
| `x_trapi.maturity.value`, `x_trapi.location.value` | `development` / `staging` / `production` and `RENCI` / `ITRB`; reported by the API. |
| `app.otel.*` | OpenTelemetry export to Jaeger. |
| `solr.resources`, `solr.storage`, `solr.heap_mem` | Sizing. Read the comments in `values.yaml` first: raising the memory limit without raising the heap is the intended way to speed up queries. |
| `forceRun` | Run the blocklist Job even when `dataUrl` is empty. |

## Installing

Example for RENCI Exp; substitute your namespace and values files. Release name
`name-lookup` gives the resource names used below (`name-lookup-solr-dep-0`,
`name-lookup-restore-job`, `name-lookup-web-svc`). With another release name they are
prefixed `<release>-name-lookup-`.

1. Install with `dataUrl` set. The environment values files already set it to the
   current release; to load something else, override it:

   ```shell
   cd helm/name-lookup
   helm install -n translator-exp -f values-populated.yaml -f renci-exp-values-populated.yaml name-lookup .
   # or, for a bare instance with no blocklist and no ingress:
   helm install -n my-namespace --set dataUrl=https://example.org/snapshot.backup.tar.gz name-lookup .
   ```

2. What happens next:
   - An init container on the Solr pod downloads the tarball and extracts it into the
     Solr data volume. The current index is about 110Gi, so this takes a while. The
     download resumes if interrupted and the container fails (and is retried) rather
     than starting Solr on a partial extract.
   - Solr starts and auto-discovers the `name_lookup` core: schema and config are inside
     the backup, so nothing is created or applied.
   - The web pod starts and becomes ready once `/status` answers.
   - If a blocklist is configured, the restore Job waits for Solr, downloads the
     blocklist and deletes those CURIEs. It is idempotent.

3. Watch the load:

   ```shell
   kubectl -n translator-exp logs -f name-lookup-solr-dep-0 -c name-lookup-download-backup
   kubectl -n translator-exp logs -f job/name-lookup-restore-job
   ```

4. Check the result. `numDocs` should match the document count reported when the
   backup was built, and the Babel and NameRes versions should be what you expect:

   ```shell
   kubectl -n translator-exp port-forward svc/name-lookup-web-svc 2433:2433
   curl -s localhost:2433/status
   curl -s 'localhost:2433/lookup?string=oxycodone&limit=3'
   ```

   `helm test -n translator-exp name-lookup` does the same `/status` check from
   inside the cluster.

5. **Lock the data in place.** Run the same command as `helm upgrade` with `dataUrl`
   cleared:

   ```shell
   helm upgrade -n translator-exp -f values-populated.yaml -f renci-exp-values-populated.yaml --set dataUrl='' name-lookup .
   ```

   This removes the init container and the restore Job, so no later `helm upgrade`
   (a chart change, a bumped default `dataUrl` in `values.yaml`, an edited values file)
   can wipe and reload the index without you deciding to. The Solr pod restarts once
   because its template changed.

   Keep `--set dataUrl=''` on every subsequent upgrade. If you forget it, the init
   container comes back and compares the configured `dataUrl` with the URL it recorded
   when it extracted the index. If they match, it skips the download and the Solr pod only
   restarts. If they differ, for example because `values.yaml` or the environment file has
   since moved on to a newer Babel release, it **deletes the index and downloads the new
   one**, and NameRes is down for the whole reload.

## Upgrading

**New NameRes version, same data.** Change `webServer.image.tag` and upgrade with
`dataUrl` still cleared:

```shell
helm upgrade -n translator-exp -f values-populated.yaml -f renci-exp-values-populated.yaml --set dataUrl='' name-lookup .
```

**New Babel release.** Update `dataUrl` and `data.*` in the environment values file (and
the defaults in `values.yaml`, `appVersion` in `Chart.yaml`, and `ncats-images-meta.yaml`
for ITRB), then upgrade *without* clearing `dataUrl`. The init container sees that the
recorded URL differs, deletes the old index and downloads the new one. NameRes is down
while this happens. When `/status` shows the new release, lock it as in step 5.

**Re-run the blocklist only** (for example after the blocklist changed): delete the old
Job and upgrade with `forceRun`:

```shell
kubectl -n translator-exp delete job name-lookup-restore-job
helm upgrade -n translator-exp -f values-populated.yaml -f renci-exp-values-populated.yaml --set dataUrl='' --set forceRun=true name-lookup .
```

## Blocklist

The blocklist is a text file with one CURIE per line, read from `blocklist.url`. The
Translator blocklist lives in the private repository NCATSTranslator/Blocklists, so the
chart always needs a GitHub personal access token with read access to it in
`blocklist.secrets.github_personal_access_token`, and refuses to render when
`blocklist.url` is set without one. Both the URL and the token live in the encrypted
`values-populated.yaml`, which every environment layers; don't override the URL per
environment. For an instance outside this repository, create the secret by hand:

```shell
kubectl -n translator-exp create secret generic name-lookup-secrets --from-literal=github_personal_access_token=github_pat_...
```

Leave `blocklist.url` empty to turn the blocklist off.

## Uninstalling

```shell
helm uninstall -n translator-exp name-lookup
```

The Solr persistent volume claim (`name-lookup-solr-data-vol-name-lookup-solr-dep-0`)
survives the uninstall. A reinstall with the same release name picks it up again, and the
init container skips the download if the recorded `dataUrl` matches. Delete the PVC by
hand if you want the disk back.

## Rendering without deploying

```shell
helm template -f values-populated.yaml -f renci-exp-values-populated.yaml name-lookup .
helm install -f values-populated.yaml -f renci-exp-values-populated.yaml --dry-run --debug name-lookup .
```
