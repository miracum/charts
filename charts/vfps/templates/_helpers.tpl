{{/*
Expand the name of the chart.
*/}}
{{- define "vfps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vfps.fullname" -}}
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
{{- define "vfps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vfps.labels" -}}
helm.sh/chart: {{ include "vfps.chart" . }}
{{ include "vfps.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "vfps.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vfps.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vfps.serviceAccountName" -}}
{{- if (or .Values.serviceAccount.create .Values.migrationsJob.enabled) }}
{{- default (include "vfps.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "vfps.migrationsJob.serviceAccountName" -}}
{{- if .Values.migrationsJob.serviceAccount.create }}
{{- default (include "vfps.migrationsJob.resourceName" .) .Values.migrationsJob.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.migrationsJob.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the container image for the wait-for-db init container
*/}}
{{- define "vfps.waitForDatabaseInitContainerImage" -}}
{{- $registry := .Values.waitForDatabaseInitContainer.image.registry -}}
{{- $repository := .Values.waitForDatabaseInitContainer.image.repository -}}
{{- $tag := .Values.waitForDatabaseInitContainer.image.tag -}}
{{ printf "%s/%s:%s" $registry $repository $tag}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name. TODO: could we use SubChart template rendering to render this?
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "vfps.postgresql.fullname" -}}
{{- $name := default "postgres" .Values.postgres.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "vfps.database.host" -}}
{{- ternary (include "vfps.postgresql.fullname" .) .Values.database.host .Values.postgres.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "vfps.database.user" -}}
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
{{- define "vfps.database.name" -}}
{{- ternary .Values.postgres.auth.database .Values.database.database .Values.postgres.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "vfps.database.port" -}}
{{- ternary "5432" .Values.database.port .Values.postgres.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "vfps.database.db-secret-name" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ .Values.postgres.auth.existingSecret | quote }}
    {{- else -}}
        {{ ( include "vfps.postgresql.fullname" . ) }}
    {{- end -}}
{{- else if .Values.database.existingSecret -}}
    {{ .Values.database.existingSecret | quote }}
{{- else -}}
    {{- $fullname := ( include "vfps.fullname" . ) -}}
    {{ printf "%s-%s" $fullname "db-secret" }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "vfps.database.db-secret-key" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ default "postgres-password" .Values.postgres.auth.secretKeys.passwordKey }}
    {{- else -}}
        {{ "postgres-password" }}
    {{- end -}}
{{- else if .Values.database.existingSecret -}}
    {{ .Values.database.existingSecretKey | quote }}
{{- else -}}
    {{ "postgres-password" }}
{{- end -}}
{{- end -}}

{{/*
Create the connection string from the host, port and database name.
*/}}
{{- define "vfps.database.connection-string" -}}
{{- $host := (include "vfps.database.host" .) -}}
{{- $port := (include "vfps.database.port" .) -}}
{{- $databaseName := (include "vfps.database.name" .) -}}
{{- $releaseName := (include "vfps.fullname" .) -}}
{{- $appName := printf "%s" $releaseName -}}
{{- $additionalConnectionStringParameters := printf "%s" .Values.database.additionalConnectionStringParameters -}}
{{- $schema := printf "%s" .Values.database.schema -}}
{{ (printf "Host=%s:%d;Database=%s;Application Name=%s;%s%s" $host (int $port) $databaseName $appName (empty $schema | ternary "" (printf "Search Path=%s;" $schema)) $additionalConnectionStringParameters) | quote }}
{{- end -}}

{{/*
get the version of the image tag to use as an identifier. Default to .Chart.Version to handle things like tags used for testing.
*/}}
{{- define "vfps.migrationsJob.versionIdentifier" -}}
{{- $imageTagVersion := (default .Chart.Version (first (splitList "@" .Values.image.tag))) | replace "." "-" -}}
{{- $imageTagVersion }}
{{- end -}}

{{/*
get the name of the migrations Job resource
*/}}
{{- define "vfps.migrationsJob.resourceName" -}}
{{ include "vfps.fullname" . }}-migrations-{{ include "vfps.migrationsJob.versionIdentifier" . }}
{{- end -}}

{{/*
Name of the secret holding the S3 credentials
*/}}
{{- define "vfps.s3.secret-name" -}}
{{- if .Values.s3.existingSecret -}}
{{ .Values.s3.existingSecret }}
{{- else -}}
{{ include "vfps.fullname" . }}-s3-secret
{{- end -}}
{{- end -}}

{{/*
Keys within the S3 credentials secret. The configurable names apply only to an existing secret -
the chart-created one always uses accessKey/secretKey, so those two settings can't accidentally
point at keys that were never written.
*/}}
{{- define "vfps.s3.access-key-key" -}}
{{- ternary .Values.s3.existingSecretAccessKeyKey "accessKey" (not (empty .Values.s3.existingSecret)) -}}
{{- end -}}

{{- define "vfps.s3.secret-key-key" -}}
{{- ternary .Values.s3.existingSecretSecretKeyKey "secretKey" (not (empty .Values.s3.existingSecret)) -}}
{{- end -}}

{{/*
S3 configuration as environment variables, shared by the API and worker Deployments (the
migrations job never touches object storage). Emits nothing at all when s3.enabled is false, so a
deployment still configuring S3 through extraEnv keeps working unchanged.
*/}}
{{- define "vfps.s3.env" -}}
{{- if .Values.s3.enabled -}}
{{- if not .Values.s3.bucket }}
{{- fail "s3.enabled requires s3.bucket to be set" }}
{{- end }}
{{- if not .Values.s3.serviceUrl }}
{{- fail "s3.enabled requires s3.serviceUrl to be set (the S3-compatible endpoint URL)" }}
{{- end }}
{{- if not (or .Values.s3.existingSecret (and .Values.s3.accessKey .Values.s3.secretKey)) }}
{{- fail "s3.enabled requires either s3.existingSecret, or both s3.accessKey and s3.secretKey" }}
{{- end }}
- name: S3__IsEnabled
  value: "true"
- name: S3__ServiceUrl
  value: {{ .Values.s3.serviceUrl | quote }}
- name: S3__Bucket
  value: {{ .Values.s3.bucket | quote }}
- name: S3__Region
  value: {{ .Values.s3.region | quote }}
- name: S3__ForcePathStyle
  value: {{ .Values.s3.forcePathStyle | quote }}
- name: S3__PresignedUrlExpiry
  value: {{ .Values.s3.presignedUrlExpiry | quote }}
- name: S3__ObjectRetentionDays
  value: {{ .Values.s3.objectRetentionDays | quote }}
{{- range $index, $origin := .Values.s3.allowedOrigins }}
- name: S3__AllowedOrigins__{{ $index }}
  value: {{ $origin | quote }}
{{- end }}
- name: S3__AccessKey
  valueFrom:
    secretKeyRef:
      name: {{ include "vfps.s3.secret-name" . }}
      key: {{ include "vfps.s3.access-key-key" . }}
- name: S3__SecretKey
  valueFrom:
    secretKeyRef:
      name: {{ include "vfps.s3.secret-name" . }}
      key: {{ include "vfps.s3.secret-key-key" . }}
{{- end -}}
{{- end -}}
