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
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Return the gPAS basic auth credentials
*/}}
{{- define "fhir-pseudonymizer.gpasBasicAuthSecretName" -}}
{{- if .Values.gpas.auth.basic.existingSecret -}}
    {{- printf "%s" (tpl .Values.gpas.auth.basic.existingSecret $) -}}
{{- else -}}
    {{ printf "%s-%s" .Release.Name "gpas-auth" }}
{{- end -}}
{{- end -}}

{{/*
Return the fhir-pseudonymizer api key
*/}}
{{- define "fhir-pseudonymizer.fhirPseudonymizerApiKeySecretName" -}}
{{- if .Values.auth.apiKey.existingSecret -}}
    {{- printf "%s" (tpl .Values.auth.apiKey.existingSecret $) -}}
{{- else -}}
    {{ printf "%s-%s" .Release.Name "fhir-pseudonymizer-api-key" }}
{{- end -}}
{{- end -}}

{{- define "fhir-pseudonymizer.utils.joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}},{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}
