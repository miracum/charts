{{/*
Expand the name of the chart.
*/}}
{{- define "datashield.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datashield.fullname" -}}
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
{{- define "datashield.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "datashield.labels" -}}
helm.sh/chart: {{ include "datashield.chart" . }}
{{ include "datashield.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "datashield.selectorLabels" -}}
app.kubernetes.io/name: {{ include "datashield.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "datashield.serviceAccountName" -}}
{{- if (or .Values.serviceAccount.create .Values.migrationsJob.enabled) }}
{{- default (include "datashield.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Get the container image for the wait-for-db init container
*/}}
{{- define "datashield.waitForDatabaseInitContainerImage" -}}
{{- $registry := .Values.waitForDatabaseInitContainer.image.registry -}}
{{- $repository := .Values.waitForDatabaseInitContainer.image.repository -}}
{{- $tag := .Values.waitForDatabaseInitContainer.image.tag -}}
{{ printf "%s/%s:%s" $registry $repository $tag}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name. TODO: could we use SubChart template rendering to render this?
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "datashield.postgresql.fullname" -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "datashield.database.host" -}}
{{- ternary (include "datashield.postgresql.fullname" .) .Values.opal.database.data.host .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "datashield.database.port" -}}
{{- ternary "5432" .Values.opal.database.data.port .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "datashield.database.user" -}}
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
{{- define "datashield.database.name" -}}
{{- ternary .Values.postgresql.auth.database .Values.opal.database.data.database .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "datashield.database.db-secret-name" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.existingSecret -}}
        {{ .Values.postgresql.auth.existingSecret | quote }}
    {{- else -}}
        {{ ( include "datashield.postgresql.fullname" . ) }}
    {{- end -}}
{{- else if .Values.opal.database.data.existingSecret.name -}}
    {{ .Values.opal.database.data.existingSecret.name | quote }}
{{- else -}}
    {{- $fullname := ( include "datashield.fullname" . ) -}}
    {{ printf "%s-%s" $fullname "db-secret" }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "datashield.database.db-secret-key" -}}
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
{{- define "datashield.database.ids.host" -}}
{{- ternary (include "datashield.postgresql.fullname" .) .Values.opal.database.ids.host .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "datashield.database.ids.port" -}}
{{- ternary "5432" .Values.opal.database.ids.port .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "datashield.database.ids.user" -}}
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
{{- define "datashield.database.ids.name" -}}
{{- ternary .Values.postgresql.auth.database .Values.opal.database.ids.database .Values.postgresql.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "datashield.database.ids.db-secret-name" -}}
{{- if .Values.postgresql.enabled -}}
    {{- if .Values.postgresql.auth.existingSecret -}}
        {{ .Values.postgresql.auth.existingSecret | quote }}
    {{- else -}}
        {{ ( include "datashield.postgresql.fullname" . ) }}
    {{- end -}}
{{- else if .Values.opal.database.ids.existingSecret.name -}}
    {{ .Values.opal.database.ids.existingSecret.name | quote }}
{{- else -}}
    {{- $fullname := ( include "datashield.fullname" . ) -}}
    {{ printf "%s-%s" $fullname "db-secret" }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "datashield.database.ids.db-secret-key" -}}
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
{{- define "datashield.storage.class" -}}
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
{{- define "datashield.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end -}}

{{- define "datashield.rock-hosts" -}}
{{- $rockServiceName := printf "%s-rock" (include "datashield.fullname" .) -}}
{{- $rock := list -}}
{{- range int .Values.rock.replicaCount | until -}}
{{- $rock = printf "%s-%d.%s:%d" $rockServiceName . $rockServiceName (int $.Values.rock.service.port) | append $rock -}}
{{- end -}}
{{- join "," $rock -}}
{{- end -}}

{{/*
Get the name of the secret containing the admin password
*/}}
{{- define "datashield.auth.admin-secret-name" -}}
{{- if empty .Values.opal.auth.administrator.existingSecret.name -}}
    {{- $secretName := printf "%s-opal-administrator" (include "datashield.fullname" .) -}}
    {{ $secretName }}
{{- else -}}
    {{ .Values.opal.auth.administrator.existingSecret.name }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the admin password
*/}}
{{- define "datashield.auth.admin-secret-key" -}}
{{- if empty .Values.opal.auth.administrator.existingSecret.name -}}
    {{ "administrator-password" }}
{{- else -}}
    {{ .Values.opal.auth.administrator.existingSecret.key }}
{{- end -}}
{{- end -}}

{{/*
Get the name of the secret containing the rock admin password
*/}}
{{- define "datashield.rock.auth.admin-secret-name" -}}
{{- if empty .Values.rock.auth.administrator.existingSecret.name -}}
    {{- $secretName := printf "%s-rock-users" (include "datashield.fullname" .) -}}
    {{ $secretName }}
{{- else -}}
    {{ .Values.rock.auth.administrator.existingSecret.name }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the rock admin password
*/}}
{{- define "datashield.rock.auth.admin-secret-key" -}}
{{- if empty .Values.rock.auth.administrator.existingSecret.name -}}
    {{ "administrator-password" }}
{{- else -}}
    {{ .Values.rock.auth.administrator.existingSecret.key }}
{{- end -}}
{{- end -}}

{{/*
Get the name of the secret containing the rock manager password
*/}}
{{- define "datashield.rock.auth.manager-secret-name" -}}
{{- if empty .Values.rock.auth.manager.existingSecret.name -}}
    {{- $secretName := printf "%s-rock-users" (include "datashield.fullname" .) -}}
    {{ $secretName }}
{{- else -}}
    {{ .Values.rock.auth.manager.existingSecret.name }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the rock manager password
*/}}
{{- define "datashield.rock.auth.manager-secret-key" -}}
{{- if empty .Values.rock.auth.manager.existingSecret.name -}}
    {{ "manager-password" }}
{{- else -}}
    {{ .Values.rock.auth.manager.existingSecret.key }}
{{- end -}}
{{- end -}}

{{/*
Get the name of the secret containing the rock user password
*/}}
{{- define "datashield.rock.auth.user-secret-name" -}}
{{- if empty .Values.rock.auth.user.existingSecret.name -}}
    {{- $secretName := printf "%s-rock-users" (include "datashield.fullname" .) -}}
    {{ $secretName }}
{{- else -}}
    {{ .Values.rock.auth.user.existingSecret.name }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the rock user password
*/}}
{{- define "datashield.rock.auth.user-secret-key" -}}
{{- if empty .Values.rock.auth.user.existingSecret.name -}}
    {{ "user-password" }}
{{- else -}}
    {{ .Values.rock.auth.user.existingSecret.key }}
{{- end -}}
{{- end -}}

{{- define "datashield.opal.ingress-hosts" -}}
{{- $hosts := list -}}
{{- range .Values.opal.ingress.hosts -}}
{{- $hosts = printf "%s" .host | append $hosts -}}
{{- end -}}
{{- join "," $hosts -}}
{{- end -}}
