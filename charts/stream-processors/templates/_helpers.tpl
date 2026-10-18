{{/* vim: set filetype=mustache: */}}

{{/*
Common labels
*/}}
{{- define "stream-processors.labels" -}}
helm.sh/chart: {{ include "common.names.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
version label value
*/}}
{{- define "stream-processors.version-label-value" -}}
{{- $tagAsString := (toString .container.image.tag) }}
{{- if contains "@" $tagAsString }}
{{- $split := regexSplit "@" $tagAsString 2 }}
    {{- $split | first | trunc 63 | quote }}
{{- else }}
    {{- $tagAsString | trunc 63 | quote }}
{{- end }}
{{- end }}

{{- define "stream-processors.utils.joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}},{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}

{{- define "stream-processors.utils.joinListWithSemicolon" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}};{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}

