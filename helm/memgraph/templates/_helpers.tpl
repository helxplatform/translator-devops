{{/*
Base name for the chart
*/}}
{{- define "memgraph.name" -}}
memgraph
{{- end }}

{{/*
Full name for resources (release-safe)
*/}}
{{- define "memgraph.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "memgraph.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Dump PVC name
*/}}
{{- define "memgraph.dumpPVCName" -}}
{{- printf "%s-dump" (include "memgraph.fullname" .) -}}
{{- end }}

{{/*
Common labels
*/}}
{{- define "memgraph.labels" -}}
app.kubernetes.io/name: {{ include "memgraph.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels (must match exactly)
*/}}
{{- define "memgraph.selectorLabels" -}}
app.kubernetes.io/name: {{ include "memgraph.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

