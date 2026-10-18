{{/*
Create the name of the service account to use
*/}}
{{- define "hive-metastore.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
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
    {{- $fullname := ( include "common.names.fullname" . ) -}}
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
