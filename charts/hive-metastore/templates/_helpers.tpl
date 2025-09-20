{{/*
Expand the name of the chart.
*/}}
{{- define "hive-metastore.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hive-metastore.fullname" -}}
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
{{- define "hive-metastore.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hive-metastore.labels" -}}
helm.sh/chart: {{ include "hive-metastore.chart" . }}
{{ include "hive-metastore.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hive-metastore.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hive-metastore.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hive-metastore.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hive-metastore.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified postgresql name. TODO: could we use SubChart template rendering to render this?
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "hive-metastore.postgresql.fullname" -}}
{{- $name := default "postgres" .Values.postgres.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "hive-metastore.database.host" -}}
{{- ternary (include "hive-metastore.postgresql.fullname" .) .Values.database.host .Values.postgres.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "hive-metastore.database.user" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.username -}}
        {{ .Values.postgres.auth.username | quote }}
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
{{- define "hive-metastore.database.name" -}}
{{- ternary .Values.postgres.auth.database .Values.database.database .Values.postgres.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "hive-metastore.database.port" -}}
{{- ternary "5432" .Values.database.port .Values.postgres.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "hive-metastore.database.db-secret-name" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ .Values.postgres.auth.existingSecret | quote }}
    {{- else -}}
        {{ ( include "hive-metastore.postgresql.fullname" . ) }}
    {{- end -}}
{{- else if .Values.database.existingSecret.name -}}
    {{ .Values.database.existingSecret.name | quote }}
{{- else -}}
    {{- $fullname := ( include "hive-metastore.fullname" . ) -}}
    {{ printf "%s-%s" $fullname "db-password" }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "hive-metastore.database.db-secret-key" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ default "postgres-password" .Values.postgres.auth.secretKeys.passwordKey }}
    {{- else -}}
        {{ "postgres-password" }}
    {{- end -}}
{{- else if .Values.database.existingSecret.name -}}
    {{ .Values.database.existingSecret.key | quote }}
{{- else -}}
    {{ "postgres-password" }}
{{- end -}}
{{- end -}}
