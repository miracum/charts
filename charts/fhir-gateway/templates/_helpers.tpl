{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fhir-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fhir-gateway.fullname" -}}
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
{{- define "fhir-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "fhir-gateway.labels" -}}
helm.sh/chart: {{ include "fhir-gateway.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Return the Postgres sink credentials secret name
*/}}
{{- define "fhir-gateway.postgresSecretName" -}}
{{- if .Values.sinks.postgres.external.existingSecret -}}
    {{- printf "%s" (tpl .Values.sinks.postgres.external.existingSecret $) -}}
{{- else if index .Values "postgresql" "enabled" -}}
    {{ printf "%s-%s" .Release.Name "postgresql" }}
{{- else -}}
    {{ printf "%s-%s" .Release.Name "postgres-secret" }}
{{- end -}}
{{- end -}}

{{/*
Return the gPAS basic auth credentials
*/}}
{{- define "fhir-gateway.gpasBasicAuthSecretName" -}}
{{- if .Values.gpas.auth.basic.existingSecret -}}
    {{- printf "%s" (tpl .Values.gpas.auth.basic.existingSecret $) -}}
{{- else -}}
    {{ printf "%s-%s" .Release.Name "gpas-auth" }}
{{- end -}}
{{- end -}}

{{/*
Return the fhir-pseudonymizer api key
*/}}
{{- define "fhir-gateway.fhirPseudonymizerApiKeySecretName" -}}
{{- if .Values.fhirPseudonymizer.auth.apiKey.existingSecret -}}
    {{- printf "%s" (tpl .Values.fhirPseudonymizer.auth.apiKey.existingSecret $) -}}
{{- else -}}
    {{ printf "%s-%s" .Release.Name "fhir-pseudonymizer-api-key" }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fhir-gateway.postgresql.host" -}}
{{- $name := "postgresql" -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the JDBC URL from the host, port and database name.
*/}}
{{- define "fhir-gateway.sinks.postgres.jdbcUrl" -}}
{{- $appName := printf "%s-fhir-gateway" .Release.Name -}}
{{- if index .Values "postgresql" "enabled" }}
{{- $host := (include "fhir-gateway.postgresql.host" .) -}}
{{ printf "jdbc:postgresql://%s:5432/%s?ApplicationName=%s" $host (index .Values "postgresql" "postgresqlDatabase" ) $appName }}
{{- else -}}
{{ printf "jdbc:postgresql://%s:%d/%s?ApplicationName=%s" .Values.sinks.postgres.external.host (int64 .Values.sinks.postgres.external.port) .Values.sinks.postgres.external.database $appName }}
{{- end -}}
{{- end -}}

{{- define "fhir-gateway.utils.joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}},{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}
