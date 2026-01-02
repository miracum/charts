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
{{- $name := default "postgres" .Values.postgres.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.host" -}}
{{- ternary (include "opal.postgresql.fullname" .) .Values.opal.database.data.host .Values.postgres.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.port" -}}
{{- ternary "5432" .Values.opal.database.data.port .Values.postgres.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.user" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.username -}}
        {{ .Values.postgres.auth.username | quote }}
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
{{- ternary .Values.postgres.auth.database .Values.opal.database.data.database .Values.postgres.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "opal.database.db-secret-name" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ .Values.postgres.auth.existingSecret | quote }}
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
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ default "postgres-password" .Values.postgres.auth.secretKeys.passwordKey }}
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
{{- ternary (include "opal.postgresql.fullname" .) .Values.opal.database.ids.host .Values.postgres.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.ids.port" -}}
{{- ternary "5432" .Values.opal.database.ids.port .Values.postgres.enabled -}}
{{- end -}}

{{/*
Add environment variables to configure database values
*/}}
{{- define "opal.database.ids.user" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.username -}}
        {{ .Values.postgres.auth.username | quote }}
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
{{- ternary .Values.postgres.auth.database .Values.opal.database.ids.database .Values.postgres.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "opal.database.ids.db-secret-name" -}}
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ .Values.postgres.auth.existingSecret | quote }}
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
{{- if .Values.postgres.enabled -}}
    {{- if .Values.postgres.auth.existingSecret -}}
        {{ default "postgres-password" .Values.postgres.auth.secretKeys.passwordKey }}
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

{{- define "opal.rock-hosts" -}}
{{- $rockServiceName := printf "%s-rock" (include "opal.fullname" .) -}}
{{- $rock := list -}}
{{- range int .Values.rock.replicaCount | until -}}
{{- $rock = printf "%s-%d.%s:%d" $rockServiceName . $rockServiceName (int $.Values.rock.service.port) | append $rock -}}
{{- end -}}
{{- join "," $rock -}}
{{- end -}}

{{/*
Get the name of the secret containing the admin password
*/}}
{{- define "opal.auth.admin-secret-name" -}}
{{- if empty .Values.opal.auth.administrator.existingSecret.name -}}
    {{- $secretName := printf "%s-opal-administrator" (include "opal.fullname" .) -}}
    {{ $secretName }}
{{- else -}}
    {{ .Values.opal.auth.administrator.existingSecret.name }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the admin password
*/}}
{{- define "opal.auth.admin-secret-key" -}}
{{- if empty .Values.opal.auth.administrator.existingSecret.name -}}
    {{ "administrator-password" }}
{{- else -}}
    {{ .Values.opal.auth.administrator.existingSecret.key }}
{{- end -}}
{{- end -}}

{{/*
Get the name of the secret containing the rock admin password
*/}}
{{- define "opal.rock.auth.admin-secret-name" -}}
{{- if empty .Values.rock.auth.administrator.existingSecret.name -}}
    {{- $secretName := printf "%s-rock-users" (include "opal.fullname" .) -}}
    {{ $secretName }}
{{- else -}}
    {{ .Values.rock.auth.administrator.existingSecret.name }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the rock admin password
*/}}
{{- define "opal.rock.auth.admin-secret-key" -}}
{{- if empty .Values.rock.auth.administrator.existingSecret.name -}}
    {{ "administrator-password" }}
{{- else -}}
    {{ .Values.rock.auth.administrator.existingSecret.key }}
{{- end -}}
{{- end -}}

{{/*
Get the name of the secret containing the rock manager password
*/}}
{{- define "opal.rock.auth.manager-secret-name" -}}
{{- if empty .Values.rock.auth.manager.existingSecret.name -}}
    {{- $secretName := printf "%s-rock-users" (include "opal.fullname" .) -}}
    {{ $secretName }}
{{- else -}}
    {{ .Values.rock.auth.manager.existingSecret.name }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the rock manager password
*/}}
{{- define "opal.rock.auth.manager-secret-key" -}}
{{- if empty .Values.rock.auth.manager.existingSecret.name -}}
    {{ "manager-password" }}
{{- else -}}
    {{ .Values.rock.auth.manager.existingSecret.key }}
{{- end -}}
{{- end -}}

{{/*
Get the name of the secret containing the rock user password
*/}}
{{- define "opal.rock.auth.user-secret-name" -}}
{{- if empty .Values.rock.auth.user.existingSecret.name -}}
    {{- $secretName := printf "%s-rock-users" (include "opal.fullname" .) -}}
    {{ $secretName }}
{{- else -}}
    {{ .Values.rock.auth.user.existingSecret.name }}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the rock user password
*/}}
{{- define "opal.rock.auth.user-secret-key" -}}
{{- if empty .Values.rock.auth.user.existingSecret.name -}}
    {{ "user-password" }}
{{- else -}}
    {{ .Values.rock.auth.user.existingSecret.key }}
{{- end -}}
{{- end -}}

{{- define "opal.opal.ingress-hosts" -}}
{{- $hosts := list -}}
{{- range .Values.opal.ingress.hosts -}}
{{- $hosts = printf "%s" .host | append $hosts -}}
{{- end -}}
{{- join "," $hosts -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "opal.opal.serviceAccountName" -}}
{{- if .Values.opal.serviceAccount.create }}
{{- default (include "opal.fullname" .) .Values.opal.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.opal.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "opal.rock.serviceAccountName" -}}
{{- if .Values.rock.serviceAccount.create }}
{{- default (include "opal.fullname" .) .Values.rock.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.rock.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
The JSON-encoded pod spec for the rock pods when using the Kubernetes pod spawner
*/}}
{{- define "opal.opal.rock-pod-specs" -}}
{{- (include "common.tplvalues.render" (dict "value" .Values.opal.pod.specs "context" $)) | fromYamlArray | toJson | toString }}
{{- end }}

              
              
