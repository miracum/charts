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
app.kubernetes.io/name: {{ include "fhir-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "fhir-gateway.matchLabels" -}}
app.kubernetes.io/name: {{ include "fhir-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "fhir-gateway.db-secret-name" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ .Values.postgres.auth.existingSecret | quote }}
    {{- else -}}
        {{ ( include "fhir-gateway.postgresql.fullname" . ) }}
    {{- end -}}
{{- else if .Values.sinks.postgres.external.existingSecret -}}
    {{ .Values.sinks.postgres.external.existingSecret | quote }}
{{- else -}}
    {{- $fullname := ( include "fhir-gateway.fullname" . ) -}}
    {{ printf "%s-%s" $fullname "postgres-secret" }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "fhir-gateway.db-secret-key" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ default "postgres-password" .Values.postgres.auth.secretKeys.passwordKey }}
    {{- else -}}
        {{ "postgres-password" }}
    {{- end -}}
{{- else if .Values.sinks.postgres.external.existingSecretKey -}}
    {{ .Values.sinks.postgres.external.existingSecretKey | quote }}
{{- else -}}
    {{ "postgresql-password" }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fhir-gateway.postgresql.fullname" -}}
{{- $name := default "postgres" .Values.postgres.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the hostname of the postgresql database
*/}}
{{- define "fhir-gateway.postgresql.host" -}}
{{- ternary (include "fhir-gateway.postgresql.fullname" .) .Values.sinks.postgres.external.host .Values.postgres.enabled -}}
{{- end -}}

{{/*
Return the database name
*/}}
{{- define "fhir-gateway.postgresql.database" -}}
{{- ternary .Values.postgres.auth.database .Values.sinks.postgres.external.database .Values.postgres.enabled -}}
{{- end -}}

{{/*
Return the database port
*/}}
{{- define "fhir-gateway.postgresql.port" -}}
{{- ternary "5432" .Values.sinks.postgres.external.port .Values.postgres.enabled -}}
{{- end -}}

{{/*
Return the database username
*/}}
{{- define "fhir-gateway.postgresql.user" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.username -}}
        {{ .Values.postgres.auth.username | quote }}
    {{- else -}}
        {{ "postgres" }}
    {{- end -}}
{{- else -}}
    {{ .Values.sinks.postgres.external.username }}
{{- end -}}
{{- end -}}

{{/*
Create the JDBC URL from the host, port and database name.
*/}}
{{- define "fhir-gateway.sinks.postgresql.jdbcUrl" -}}
{{- $appName := printf "%s-fhir-gateway" (include "fhir-gateway.fullname" .) -}}
{{- $databaseName := (include "fhir-gateway.postgresql.database" .) -}}
{{- $host := (include "fhir-gateway.postgresql.host" .) -}}
{{- $port := (include "fhir-gateway.postgresql.port" .) -}}
{{ printf "jdbc:postgresql://%s:%d/%s?ApplicationName=%s" $host (int $port) $databaseName $appName}}
{{- end -}}

{{- define "fhir-gateway.utils.joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}},{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}

{{/*
Image used to for the PostgreSQL readiness init containers
*/}}
{{- define "fhir-gateway.waitforDB.image" -}}
{{- $registry := .Values.waitForPostgresInitContainer.image.registry -}}
{{- $repository := .Values.waitForPostgresInitContainer.image.repository -}}
{{- $tag := .Values.waitForPostgresInitContainer.image.tag -}}
{{ printf "%s/%s:%s" $registry $repository $tag}}
{{- end -}}

{{/*
Base URL of the fhir-pseudonymizer service.
*/}}
{{- define "fhir-gateway.pseudonymizer.baseUrl" -}}
{{- $host := (include "fhir-pseudonymizer.fullname" (index .Subcharts "fhir-pseudonymizer")) -}}
{{- $port := (index .Values "fhir-pseudonymizer" "service" "port") -}}
{{ printf "http://%s:%d/fhir" $host (int $port) }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "fhir-gateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fhir-gateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
