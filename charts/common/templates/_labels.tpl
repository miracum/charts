{{/*
Labels to use on deploy.spec.selector.matchLabels, svc.spec.selector and NetworkPolicy/PDB selectors.
These are immutable on workloads, so they must not contain values that change between releases.
Usage: {{ include "common.labels.matchLabels" . }}
*/}}
{{- define "common.labels.matchLabels" -}}
app.kubernetes.io/name: {{ include "common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Kubernetes standard labels.
Usage: {{ include "common.labels.standard" . }}
*/}}
{{- define "common.labels.standard" -}}
helm.sh/chart: {{ include "common.names.chart" . }}
{{ include "common.labels.matchLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
