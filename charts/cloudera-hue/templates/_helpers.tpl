{{/*
Expand the name of the chart.
*/}}
{{- define "cloudera-hue.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cloudera-hue.fullname" -}}
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
{{- define "cloudera-hue.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cloudera-hue.labels" -}}
helm.sh/chart: {{ include "cloudera-hue.chart" . }}
{{ include "cloudera-hue.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cloudera-hue.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cloudera-hue.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cloudera-hue.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cloudera-hue.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Renders a value that contains template.
Via <https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_tplvalues.tpl>
*/}}
{{- define "cloudera-hue.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{/*
Get the container image for the wait-for-db init container
*/}}
{{- define "cloudera-hue.waitForDatabaseInitContainerImage" -}}
{{- $registry := .Values.waitForDatabaseInitContainer.image.registry -}}
{{- $repository := .Values.waitForDatabaseInitContainer.image.repository -}}
{{- $tag := .Values.waitForDatabaseInitContainer.image.tag -}}
{{ printf "%s/%s:%s" $registry $repository $tag}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name. TODO: could we use SubChart template rendering to render this?
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cloudera-hue.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "cloudera-hue.database.host" -}}
{{- ternary (include "cloudera-hue.postgresql.fullname" .) .Values.database.host .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "cloudera-hue.database.user" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.username -}}
        {{ .Values.postgresql.auth.username | quote }}
    {{- else -}}
        {{ "postgres" }}
    {{- end -}}
{{- else -}}
    {{ .Values.database.username}}
{{- end -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "cloudera-hue.database.name" -}}
{{- ternary .Values.postgresql.auth.database .Values.database.database .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "cloudera-hue.database.port" -}}
{{- ternary "5432" .Values.database.port .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "cloudera-hue.database.db-secret-name" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.existingSecret -}}
        {{ .Values.postgresql.auth.existingSecret | quote }}
    {{- else -}}
        {{ ( include "cloudera-hue.postgresql.fullname" . ) }}
    {{- end -}}
{{- else if .Values.database.existingSecret.name -}}
    {{ .Values.database.existingSecret.name | quote }}
{{- else -}}
    {{- $fullname := ( include "cloudera-hue.fullname" . ) -}}
    {{ printf "%s-%s" $fullname "db-secret" }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "cloudera-hue.database.db-secret-key" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if (or .Values.postgresql.auth.username .Values.postgresql.auth.existingSecret ) -}}
        {{ "password" }}
    {{- else -}}
        {{ "postgres-password" }}
    {{- end -}}
{{- else if .Values.database.existingSecret.name -}}
    {{ .Values.database.existingSecret.key | quote }}
{{- else -}}
    {{ "postgres-password" }}
{{- end -}}
{{- end -}}
