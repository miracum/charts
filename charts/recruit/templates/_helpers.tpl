{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "recruit.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "recruit.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "recruit.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "recruit.labels" -}}
helm.sh/chart: {{ include "recruit.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "recruit.matchLabels" . }}
{{- if .Values.extraLabels }}
    {{- toYaml .Values.extraLabels }}
{{- end }}
{{- end -}}

{{/*
Labels to use on deploy.spec.selector.matchLabels and svc.spec.selector
*/}}
{{- define "recruit.matchLabels" -}}
app.kubernetes.io/name: {{ include "recruit.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Extra labels to apply to every pod
*/}}
{{- define "recruit.podLabels" -}}
{{ include "recruit.matchLabels" . }}
{{- if and .Values.fhirserver.enabled .Values.fhirserver.networkPolicy.enabled }}
{{- $name := default "fhirserver" .Values.fhirserver.nameOverride }}
{{ printf "%s-%s-client: \"true\"" .Release.Name ($name | trunc 63 | trimSuffix "-") }}
{{- end -}}
{{- end -}}

{{/*
Get the FHIR server URL.
*/}}
{{- define "recruit.fhirserver.url" -}}
{{- if .Values.fhirserver.enabled }}
    {{- $name := default "fhirserver" .Values.fhirserver.nameOverride -}}
    {{- printf "http://%s-%s:%d/fhir" .Release.Name ($name | trunc 63 | trimSuffix "-") 8080 -}}
{{- else -}}
    {{ .Values.externalFhirServer.url | quote }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified mailhog name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "recruit.mailhog.fullname" -}}
{{- $name := default "mailhog" .Values.mailhog.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the SMTP server credentials secret.
*/}}
{{- define "recruit.mail.server.secretName" -}}
{{- if .Values.notify.mail.server.existingSecret -}}
    {{- printf "%s" .Values.notify.mail.server.existingSecret -}}
{{- else -}}
    {{ printf "%s-%s" .Release.Name "smtp" }}
{{- end -}}
{{- end -}}

{{/*
Get the notification module's endpoint for the webhook
*/}}
{{- define "recruit.notify.webhookEndpointUrl" -}}
{{- if .Values.notify.ingress.enabled -}}
    {{- $host := (index .Values.notify.ingress.hosts 0).host }}
    {{- $protocol := (empty .Values.notify.ingress.tls) | ternary "http" "https" }}
    {{- printf "%s://%s/on-list-change" $protocol $host -}}
{{- else -}}
    {{- $host := (printf "%s-%s" (include "recruit.fullname" .) "notify") -}}
    {{- printf "http://%s:%d/on-list-change" $host (.Values.notify.service.port | int64) -}}
{{- end -}}
{{- end -}}

{{- define "recruit.omop.db.host" -}}
{{- if .Values.ohdsi.enabled -}}
    {{ include "ohdsi.database.host" .Subcharts.ohdsi }}
{{- else -}}
    {{ .Values.query.omop.host }}
{{- end -}}
{{- end -}}

{{- define "recruit.omop.db.port" -}}
{{- if .Values.ohdsi.enabled -}}
    {{ include "ohdsi.database.port" .Subcharts.ohdsi }}
{{- else -}}
    {{ .Values.query.omop.port }}
{{- end -}}
{{- end -}}

{{- define "recruit.omop.db.user" -}}
{{- if .Values.ohdsi.enabled -}}
    {{ include "ohdsi.database.user" .Subcharts.ohdsi }}
{{- else -}}
    {{ .Values.query.omop.username }}
{{- end -}}
{{- end -}}

{{- define "recruit.omop.db.name" -}}
{{- if .Values.ohdsi.enabled -}}
    {{ include "ohdsi.database.name" .Subcharts.ohdsi }}
{{- else -}}
    {{ .Values.query.omop.database }}
{{- end -}}
{{- end -}}

{{/*
Get the OMOP JDBC URL.
*/}}
{{- define "recruit.omop.jdbcUrl" -}}
{{- $host := include "recruit.omop.db.host" . }}
{{- $port := include "recruit.omop.db.port" . | int64 }}
{{- $database := include "recruit.omop.db.name" . }}
{{- $appName := printf "%s-query" (include "recruit.fullname" .) -}}
{{- (printf "jdbc:postgresql://%s:%d/%s?ApplicationName=%s" $host $port $database $appName) | quote -}}
{{- end -}}

{{/*
Get the OHDSI WebAPI URL.
*/}}
{{- define "recruit.omop.webApiUrl" -}}
{{- if .Values.ohdsi.enabled -}}
    {{- if .Values.ohdsi.atlas.webApiUrl -}}
        {{ .Values.ohdsi.atlas.webApiUrl }}
    {{- else -}}
        {{- printf "http://%s-%s:%d/WebAPI" .Release.Name "ohdsi-webapi" (int64 .Values.ohdsi.webApi.service.port) -}}
    {{- end -}}
{{- else -}}
    {{ .Values.query.webAPI.url }}
{{- end -}}
{{- end -}}

{{/*
Get the screening list link template
*/}}
{{- define "recruit.notify.mail.screeningListLinkTemplate" -}}
{{- if .Values.list.ingress.enabled -}}
    {{- $host := (index .Values.list.ingress.hosts 0).host }}
    {{- $protocol := (empty .Values.list.ingress.tls) | ternary "http" "https" }}
    {{- printf "%s://%s/recommendations/[list_id]" $protocol $host -}}
{{- else -}}
    {{- .Values.notify.mail.screeningListLinkTemplate | quote -}}
{{- end -}}
{{- end -}}

{{- define "recruit.utils.joinListWithComma" -}}
{{- $local := dict "first" true -}}
{{- range $k, $v := . -}}{{- if not $local.first -}},{{- end -}}{{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}

{{/*
Return the OMOP credentials secret name
*/}}
{{- define "recruit.omopSecretName" -}}
{{- if .Values.ohdsi.enabled -}}
    {{ include "ohdsi.webapi.db-secret-name" .Subcharts.ohdsi }}
{{- else -}}
    {{- if .Values.query.omop.existingSecret -}}
        {{ printf "%s" (tpl .Values.query.omop.existingSecret $) }}
    {{- else -}}
        {{ printf "%s-%s" .Release.Name "query-omop-secret" }}
    {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the OMOP credentials secret key
*/}}
{{- define "recruit.omopSecretKey" -}}
{{- if .Values.ohdsi.enabled -}}
    {{ include "ohdsi.webapi.db-secret-key" .Subcharts.ohdsi }}
{{- else -}}
    {{ printf "%s" "omop-password" }}
{{- end -}}
{{- end -}}

{{/*
Return the OMOP DB password when not using an existing secret
*/}}
{{- define "recruit.omop.password" -}}
{{- if .Values.ohdsi.enabled -}}
    {{ .Values.ohdsi.webApi.db.password}}
{{- else -}}
    {{ .Values.query.omop.password }}
{{- end -}}
{{- end -}}

{{- define "recruit.webApiSecretName" -}}
{{- if .Values.query.webAPI.auth.existingSecret.name -}}
    {{ printf "%s" (tpl .Values.query.webAPI.auth.existingSecret.name $) }}
{{- else -}}
    {{ printf "%s-%s" .Release.Name "query-webapi-secret" }}
{{- end -}}
{{- end -}}

{{- define "recruit.webApiSecretKey" -}}
{{- if .Values.query.webAPI.auth.existingSecret.key -}}
    {{ printf "%s" (tpl .Values.query.webAPI.auth.existingSecret.key $) }}
{{- else -}}
    {{ printf "%s" "webApiAuthPassword" }}
{{- end -}}
{{- end -}}

{{/*
Image used to for the PostgreSQL readiness init containers
*/}}
{{- define "recruit.waitforDB.image" -}}
{{- $registry := .Values.waitForPostgresInitContainer.image.registry -}}
{{- $repository := .Values.waitForPostgresInitContainer.image.repository -}}
{{- $tag := .Values.waitForPostgresInitContainer.image.tag -}}
{{ printf "%s/%s:%s" $registry $repository $tag}}
{{- end -}}

{{- define "recruit.notify.database.host" -}}
{{- if .Values.postgresql.enabled -}}
    {{ printf "%s-%s" .Release.Name .Values.postgresql.nameOverride }}
{{- else -}}
    {{ .Values.notify.ha.database.host }}
{{- end -}}
{{- end -}}

{{- define "recruit.notify.database.port" -}}
{{- ternary "5432" .Values.notify.ha.database.port .Values.postgresql.enabled -}}
{{- end -}}

{{- define "recruit.notify.database.username" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.username -}}
        {{ .Values.postgresql.auth.username | quote }}
    {{- else -}}
        {{ "postgres" }}
    {{- end -}}
{{- else -}}
    {{ .Values.notify.ha.database.username }}
{{- end -}}
{{- end -}}

{{- define "recruit.notify.database.name" -}}
{{- ternary .Values.postgresql.auth.database .Values.notify.ha.database.name .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Create the JDBC URL from the host, port and database name.
*/}}
{{- define "recruit.notify.database.jdbcUrl" -}}
{{- $host := (include "recruit.notify.database.host" .) -}}
{{- $port := (include "recruit.notify.database.port" .) -}}
{{- $name := (include "recruit.notify.database.name" .) -}}
{{- $appName := printf "%s-notify" (include "recruit.fullname" .) -}}
{{ printf "jdbc:postgresql://%s:%d/%s?ApplicationName=%s" $host (int $port) $name $appName}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "recruit.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "recruit.notify.database.secretName" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.existingSecret -}}
        {{ .Values.postgresql.auth.existingSecret | quote }}
    {{- else -}}
        {{ ( include "recruit.postgresql.fullname" . ) }}
    {{- end -}}
{{- else if .Values.notify.ha.database.existingSecret.name -}}
    {{ .Values.notify.ha.database.existingSecret.name | quote }}
{{- else -}}
    {{- $fullname := ( include "recruit.fullname" . ) -}}
    {{ printf "%s-%s" $fullname "notify-ha-db" }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "recruit.notify.database.secretKey" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if (or .Values.postgresql.auth.username .Values.postgresql.auth.existingSecret ) -}}
        {{ "password" }}
    {{- else -}}
        {{ "postgres-password" }}
    {{- end -}}
{{- else if .Values.notify.ha.database.existingSecret.key -}}
    {{ .Values.notify.ha.database.existingSecret.key | quote }}
{{- else -}}
    {{ "postgres-password" }}
{{- end -}}
{{- end -}}
