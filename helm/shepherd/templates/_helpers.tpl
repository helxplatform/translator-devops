{{/*
Expand the name of the chart.
*/}}
{{- define "shepherd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "shepherd.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "shepherd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "shepherd.labels" -}}
helm.sh/chart: {{ include "shepherd.chart" . }}
{{ include "shepherd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "shepherd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "shepherd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Shared hash of the omnicorp loader source URLs.
Rendered identically into the loader Job (as SOURCES_HASH env) and the worker
Deployment (as a pod-template annotation), so a change to `sources`:
  - changes the loader Job pod template  -> Job re-runs on `helm upgrade`
  - changes the worker pod-template annotation -> worker rolls to pick up new data
Truncated to 12 chars to match the loader's stored .source-url-hash.
*/}}
{{- define "shepherd.omnicorpSourcesHash" -}}
{{- join "," .Values.omnicorpLoader.sources | sha256sum | trunc 12 -}}
{{- end -}}

{{/*
Shared hash of the embeddings loader source URLs. Same purpose as the omnicorp
hash above: drives loader Job re-runs and worker (score-paths) rolls when the
`embeddingsLoader.sources` value changes.
*/}}
{{- define "shepherd.embeddingsSourcesHash" -}}
{{- join "," .Values.embeddingsLoader.sources | sha256sum | trunc 12 -}}
{{- end -}}
