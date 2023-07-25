{{/*
Expand the name of the chart.
*/}}
{{- define "opal.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opal.fullname" -}}
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
{{- define "opal.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "opal.labels" -}}
helm.sh/chart: {{ include "opal.chart" . }}
{{ include "opal.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "opal.selectorLabels" -}}
app.kubernetes.io/name: {{ include "opal.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "opal.serviceAccountName" -}}
{{- if (or .Values.serviceAccount.create .Values.migrationsJob.enabled) }}
{{- default (include "opal.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Get the container image for the wait-for-db init container
*/}}
{{- define "opal.waitForDatabaseInitContainerImage" -}}
{{- $registry := .Values.waitForDatabaseInitContainer.image.registry -}}
{{- $repository := .Values.waitForDatabaseInitContainer.image.repository -}}
{{- $tag := .Values.waitForDatabaseInitContainer.image.tag -}}
{{ printf "%s/%s:%s" $registry $repository $tag}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name. TODO: could we use SubChart template rendering to render this?
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "opal.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.host" -}}
{{- ternary (include "opal.postgresql.fullname" .) .Values.opal.database.data.host .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.port" -}}
{{- ternary "5432" .Values.opal.database.data.port .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.user" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.username -}}
        {{ .Values.postgresql.auth.username | quote }}
    {{- else -}}
        {{ "postgres" }}
    {{- end -}}
{{- else -}}
    {{ .Values.opal.database.data.username}}
{{- end -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.name" -}}
{{- ternary .Values.postgresql.auth.database .Values.opal.database.data.database .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "opal.database.db-secret-name" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.existingSecret -}}
        {{ .Values.postgresql.auth.existingSecret | quote }}
    {{- else -}}
        {{ ( include "opal.postgresql.fullname" . ) }}
    {{- end -}}
{{- else if .Values.opal.database.data.existingSecret.name -}}
    {{ .Values.opal.database.data.existingSecret.name | quote }}
{{- else -}}
    {{- $fullname := ( include "opal.fullname" . ) -}}
    {{ printf "%s-%s" $fullname "db-secret" }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "opal.database.db-secret-key" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if (or .Values.postgresql.auth.username .Values.postgresql.auth.existingSecret ) -}}
        {{ "password" }}
    {{- else -}}
        {{ "postgres-password" }}
    {{- end -}}
{{- else if .Values.opal.database.data.existingSecret.name -}}
    {{ .Values.opal.database.data.existingSecret.key | quote }}
{{- else -}}
    {{ "data-db-password" }}
{{- end -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.ids.host" -}}
{{- ternary (include "opal.postgresql.fullname" .) .Values.opal.database.ids.host .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.ids.port" -}}
{{- ternary "5432" .Values.opal.database.ids.port .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.ids.user" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.username -}}
        {{ .Values.postgresql.auth.username | quote }}
    {{- else -}}
        {{ "postgres" }}
    {{- end -}}
{{- else -}}
    {{ .Values.opal.database.ids.username }}
{{- end -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.ids.name" -}}
{{- ternary .Values.postgresql.auth.database .Values.opal.database.ids.database .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "opal.database.ids.db-secret-name" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.existingSecret -}}
        {{ .Values.postgresql.auth.existingSecret | quote }}
    {{- else -}}
        {{ ( include "opal.postgresql.fullname" . ) }}
    {{- end -}}
{{- else if .Values.opal.database.ids.existingSecret.name -}}
    {{ .Values.opal.database.ids.existingSecret.name | quote }}
{{- else -}}
    {{- $fullname := ( include "opal.fullname" . ) -}}
    {{ printf "%s-%s" $fullname "db-secret" }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "opal.database.ids.db-secret-key" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if (or .Values.postgresql.auth.username .Values.postgresql.auth.existingSecret ) -}}
        {{ "password" }}
    {{- else -}}
        {{ "postgres-password" }}
    {{- end -}}
{{- else if .Values.opal.database.ids.existingSecret.name -}}
    {{ .Values.opal.database.ids.existingSecret.key | quote }}
{{- else -}}
    {{ "ids-db-password" }}
{{- end -}}
{{- end -}}

{{/*
Return  the proper Storage Class
Via <https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_storage.tpl>
*/}}
{{- define "opal.storage.class" -}}
{{- $storageClass := .persistence.storageClass -}}
{{- if .global -}}
    {{- if .global.storageClass -}}
        {{- $storageClass = .global.storageClass -}}
    {{- end -}}
{{- end -}}
{{- if $storageClass -}}
  {{- if (eq "-" $storageClass) -}}
      {{- printf "storageClassName: \"\"" -}}
  {{- else }}
      {{- printf "storageClassName: %s" $storageClass -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Renders a value that contains template.
Via <https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_tplvalues.tpl>
*/}}
{{- define "opal.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{- define "opal.rock-hosts" -}}
{{- $rockServiceName := printf "%s-rock" (include "opal.fullname" .) -}}
{{- $rock := list -}}
{{- range int .Values.rock.replicaCount | until -}}
{{- $rock = printf "%s-%d.%s:%d" $rockServiceName . $rockServiceName (int $.Values.rock.service.port) | append $rock -}}
{{- end -}}
{{- join "," $rock -}}
{{- end -}}
