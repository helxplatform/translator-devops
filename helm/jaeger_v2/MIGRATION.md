# Migrating from Jaeger v1 to Jaeger v2 (Client Developer Guide)

This guide is for developers of services/clients that previously emitted traces to a
**Jaeger v1** backend and now need to target the shared **Jaeger v2** backend deployed
from this Helm chart.

> **TL;DR for the impatient:** Jaeger v2 is built on the OpenTelemetry Collector. The
> recommended (and forward-compatible) way to send traces is **OTLP** — gRPC on port
> `4317` or HTTP on port `4318`. If your client already speaks OTLP, migration is mostly
> a matter of changing the endpoint. If it uses the legacy Jaeger SDKs/exporters, you'll
> migrate to the OpenTelemetry SDK.

## Contents

1. [What changed in Jaeger v2](#1-what-changed-in-jaeger-v2)
2. [Stand up a local all-in-one Jaeger v2 instance](#2-stand-up-a-local-all-in-one-jaeger-v2-instance) ← **start here**
3. [Point a client at the local instance](#3-point-a-client-at-the-local-instance)
4. [Migrating client instrumentation (Jaeger SDK → OpenTelemetry SDK)](#4-migrating-client-instrumentation)
5. [Pointing at the shared cluster backend](#5-pointing-at-the-shared-cluster-backend)
6. [Troubleshooting](#6-troubleshooting)

---

## 1. What changed in Jaeger v2

Jaeger v2 is a significant architectural change from v1, even though the UI looks the same:

- **One binary instead of many.** v1 had separate `jaeger-agent`, `jaeger-collector`,
  `jaeger-query`, and `jaeger-all-in-one` binaries/images. v2 is a single `jaeger`
  binary, built on the OpenTelemetry Collector, whose role is determined by its config.
- **The Jaeger Agent is gone.** In v1 the recommended path was app → agent (UDP) →
  collector. In v2 there is no agent; clients send **OTLP directly to the collector**
- **OTLP is the primary ingestion protocol.** Legacy receivers (Jaeger Thrift, Zipkin)
  still exist for backward compatibility, but OTLP (`4317`/`4318`) is the recommended
  protocol going forward.
- **New image coordinates.** The image is now
  `cr.jaegertracing.io/jaegertracing/jaeger` (note: not the old
  `jaegertracing/all-in-one`).

> This chart deploys Jaeger v2 chart version `4.8.0` / app version `2.18.0` with an
> Elasticsearch backend. See [`README.md`](./README.md) for the cluster deployment.

---

## 2. Stand up a local all-in-one Jaeger v2 instance

Before touching the shared cluster backend, get a local Jaeger v2 running so you can
validate your client emits traces correctly. The **all-in-one** image combines the
collector, query, and UI in a single process backed by transient **in-memory** storage
(traces are lost on restart — perfect for local dev, not for production).

Based on the official [Jaeger v2 getting-started guide](https://www.jaegertracing.io/docs/2.19/getting-started/).

### Prerequisites

- Docker

### Run it

```bash
docker run --rm --name jaeger \
  -p 16686:16686 \
  -p 4317:4317 \
  -p 4318:4318 \
  cr.jaegertracing.io/jaegertracing/jaeger:2.18.0
```

### Ports

| Port    | Protocol  | Purpose                                                        |
|---------|-----------|----------------------------------------------------------------|
| `16686` | HTTP      | **Jaeger UI** — open <http://localhost:16686>                  |
| `4317`  | gRPC      | **OTLP gRPC receiver** — recommended endpoint for clients      |
| `4318`  | HTTP      | **OTLP HTTP receiver** — recommended endpoint for clients      |

### Verify it's up

Open the UI at <remo>. You should see the Jaeger search page. Until a
client sends spans, the only service listed will be `jaeger` itself (it self-traces).

### Optional: the HotROD demo (a known-good trace source)

If you want to see traces flowing without instrumenting your own app first, run the
HotROD demo, which generates traces against this backend:

```bash
export JAEGER_VERSION=2.18.0
git clone https://github.com/jaegertracing/jaeger.git jaeger
cd jaeger/examples/hotrod
docker compose up
```

Then open the demo at <http://localhost:8080>, click some buttons, and find the
resulting traces under the `frontend`/`customer`/`driver` services in the Jaeger UI.

---

## 3. Point a client at the local instance

This guide assumes **your application already reads its trace destination from its own
environment variables** — not the OpenTelemetry SDK's built-in `OTEL_EXPORTER_OTLP_*`
variables. The examples below use the placeholder names **`TRACE_COLLECTOR_HOST`** and
**`TRACE_COLLECTOR_PORT`**; substitute whatever your app actually defines (e.g.
`JAEGER_HOST`/`JAEGER_PORT`, `TRACING_ENDPOINT_HOST`, etc.).

The contract is the same everywhere — only the two values change:

| Variable | Local all-in-one | In-cluster (same namespace) |
|---|---|---|
| `TRACE_COLLECTOR_HOST` | `localhost` (or `host.docker.internal` if your app runs in another container) | `jaeger-otel` |
| `TRACE_COLLECTOR_PORT` | `4317` (gRPC) or `4318` (HTTP) | `4317` (gRPC) or `4318` (HTTP) |

### Set the variables (local)

```bash
export TRACE_COLLECTOR_HOST=localhost
export TRACE_COLLECTOR_PORT=4317
```

### Build the OTLP exporter from your variables

Your app reads its own variables and constructs the OTLP endpoint. For example, in Python:

```python
import os
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.resources import Resource
# gRPC exporter (port 4317)
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

host = os.environ["TRACE_COLLECTOR_HOST"]
port = os.environ["TRACE_COLLECTOR_PORT"]

provider = TracerProvider(resource=Resource.create({"service.name": "my-service"}))
provider.add_span_processor(
    BatchSpanProcessor(
        OTLPSpanExporter(
            endpoint=f"{host}:{port}",  # e.g. "jaeger-otel:4317"
            insecure=True,              # plaintext OTLP (no TLS on the collector)
        )
    )
)
trace.set_tracer_provider(provider)
```

> **gRPC (4317) vs HTTP (4318):** for the HTTP exporter, import from
> `opentelemetry.exporter.otlp.proto.http.trace_exporter` and pass a URL with scheme and
> path, e.g. `endpoint=f"http://{host}:{port}/v1/traces"`. The gRPC exporter takes a bare
> `host:port`. Pick one protocol and the matching port.

> **The collector uses plaintext, not TLS.** Trace ingest is plain OTLP with no TLS, which
> is the normal setup for an in-cluster collector. So a gRPC client must be told the
> connection is insecure — do at least one of the following:
>
> - set `insecure=True` on the exporter in code (as shown above), or
> - set the env var `OTEL_EXPORTER_OTLP_INSECURE=true`
> - use an `http://` endpoint URL (e.g. `http://jaeger-otel:4317`).
>
> An HTTP exporter only needs `http://` as the start of the host.

### Verify

Run your app, exercise a code path, then open the local Jaeger UI at
<http://localhost:16686> and confirm `my-service` appears with traces.

## 4. Migrating client instrumentation

If your client still uses the **legacy Jaeger SDK** (`jaeger-client-*`, now deprecated and
EOL), migrate it to the **OpenTelemetry SDK** with an OTLP exporter. The Jaeger backend no
longer accepts the old agent/Thrift-over-UDP path the legacy clients used by default.

Conceptual mapping:

| Jaeger v1 client | Jaeger v2 / OpenTelemetry |
|---|---|
| `jaeger-client-{go,python,java,js,…}` SDK | OpenTelemetry SDK for your language |
| Span reporting to **agent** over UDP (`:6831`/`:6832`) | **OTLP** to the collector over gRPC (`:4317`) or HTTP (`:4318`) |
| `JAEGER_AGENT_HOST` / `JAEGER_AGENT_PORT` | your `TRACE_COLLECTOR_HOST` / `TRACE_COLLECTOR_PORT` (see §3) |
| `JAEGER_SAMPLER_TYPE` / `JAEGER_SAMPLER_PARAM` | OpenTelemetry samplers (`TracerProvider(sampler=…)`) |
| `JAEGER_SERVICE_NAME` | `service.name` resource attribute |
| Jaeger propagation headers | W3C Trace Context (OTel default); enable Jaeger propagator only if you must interop with un-migrated services |

Practical steps per service:

1. Remove the `jaeger-client` dependency; add the OpenTelemetry SDK + OTLP exporter
   packages for your language.
2. Replace tracer initialization with a `TracerProvider` + `BatchSpanProcessor` +
   `OTLPSpanExporter` wired to your custom host/port env vars (as in §3).
3. Set the `service.name` resource attribute (this is what shows up in the Jaeger UI).
4. Keep your existing custom env var **names** so deployment configs don't have to change —
   only their **values** point at the new collector.

## 5. Pointing at the shared cluster backend

The chart deploys the all-in-one as a Service named **`jaeger-otel`**
that exposes the OTLP ports cluster-internally:

- **Same namespace** — if your app is deployed in the `sri` namespace set your app's env vars to:
  - `TRACE_COLLECTOR_HOST=http://jaeger-otel`
  - `TRACE_COLLECTOR_PORT=4317` (gRPC) or `4318` (HTTP)
- **Different namespace** — include the `sri` namespace in the host:
  - `TRACE_COLLECTOR_HOST=http://jaeger-otel.sri`

Example for a consuming app's Deployment (same namespace):

```yaml
        env:
          - name: TRACE_COLLECTOR_HOST
            value: "http://jaeger-otel.sri"
          - name: TRACE_COLLECTOR_PORT
            value: "4317"
```

Notes:

- **No TLS on the OTLP endpoint.** In-cluster OTLP traffic to the collector is plaintext
  gRPC/HTTP. For the gRPC exporter, mark it insecure — either `insecure=True` in code, or
  set `OTEL_EXPORTER_OTLP_INSECURE=true` (or `OTEL_EXPORTER_OTLP_TRACES_INSECURE=true` for
  traces only) when configuring via env vars. The TLS in this chart is between Jaeger and
  Elasticsearch, and on the public UI ingress — not on the trace-ingest port.
- **Do not send traces to the UI ingress host** (`*-otel*.apps.renci.org`). That serves
  the query UI over HTTPS on 443; it is not the OTLP ingest endpoint. Traces go to the
  in-cluster Service on 4317/4318.
- **NetworkPolicy.** If a NetworkPolicy restricts ingress to the Jaeger namespace, add a
  rule allowing the app's namespace to reach `jaeger-otel` on 4317/4318.

## 6. Troubleshooting

| Symptom | Likely cause / fix |
|---|---|
| No service or traces in the UI | App can't reach the collector. Check `TRACE_COLLECTOR_HOST`/`PORT` resolve to the `jaeger-otel` Service; `kubectl exec` into the app pod and test connectivity to `jaeger-otel:4317`. |
| Connection refused / wrong port | Port must match the protocol: **4317 = gRPC**, **4318 = HTTP**. Don't mix (e.g. HTTP exporter against 4317). |
| TLS / handshake errors on ingest | The OTLP endpoint is plaintext — for gRPC use `insecure=True` or `OTEL_EXPORTER_OTLP_INSECURE=true` / `OTEL_EXPORTER_OTLP_TRACES_INSECURE=true`; for HTTP use an `http://` URL. Don't point the exporter at the HTTPS UI ingress. |
| HTTP exporter gets 404 | The OTLP HTTP exporter needs the full path: `http://<host>:4318/v1/traces`. |
| Traces appear under the wrong/blank service | Set the `service.name` resource attribute (replaces `JAEGER_SERVICE_NAME`). |
| Cross-namespace timeouts | Use the FQDN `jaeger-otel.<ns>.svc.cluster.local` and check NetworkPolicy allows the traffic. |
| Spans dropped under load | Tune the `BatchSpanProcessor` queue/batch settings, or scale the backend (see `README.md` → Future Scalability Considerations). |