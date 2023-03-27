{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fhir-pseudonymizer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fhir-pseudonymizer.fullname" -}}
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
{{- define "fhir-pseudonymizer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fhir-pseudonymizer.labels" -}}
helm.sh/chart: {{ include "fhir-pseudonymizer.chart" . }}
{{ include "fhir-pseudonymizer.matchLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "fhir-pseudonymizer.matchLabels" -}}
app.kubernetes.io/name: {{ include "fhir-pseudonymizer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the gPAS basic auth credentials
*/}}
{{- define "fhir-pseudonymizer.gpasBasicAuthSecretName" -}}
{{- if .Values.gpas.auth.basic.existingSecret -}}
    {{- printf "%s" (tpl .Values.gpas.auth.basic.existingSecret $) -}}
{{- else -}}
    {{ include "fhir-pseudonymizer.fullname" . }}-gpas-auth
{{- end -}}
{{- end -}}

{{/*
Return the fhir-pseudonymizer api key
*/}}
{{- define "fhir-pseudonymizer.fhirPseudonymizerApiKeySecretName" -}}
{{- if .Values.auth.apiKey.existingSecret -}}
    {{- printf "%s" (tpl .Values.auth.apiKey.existingSecret $) -}}
{{- else -}}
    {{ include "fhir-pseudonymizer.fullname" . }}-api-key
{{- end -}}
{{- end -}}

{{/*
Return the vfps address to use
*/}}
{{- define "fhir-pseudonymizer.isApiKeyAuthEnabled" -}}
    {{- .Values.auth.apiKey.enabled -}}
{{- end -}}

{{/*
Return the vfps address to use
*/}}
{{- define "fhir-pseudonymizer.vfpsAddress" -}}
{{- if .Values.vfps.enabled -}}
    {{- printf "dns:///%s-headless:%d" (include "vfps.fullname" .Subcharts.vfps) (int64 .Values.vfps.service.grpcPort) -}}
{{- else -}}
    {{- .Values.externalVfps.address -}}
{{- end -}}
{{- end -}}
