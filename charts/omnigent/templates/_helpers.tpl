{{/*
Create the name of the service account to use
*/}}
{{- define "omnigent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
The public base URL of the server. Uses .Values.baseUrl if set, otherwise derives it from the first ingress host.
*/}}
{{- define "omnigent.baseUrl" -}}
{{- if .Values.baseUrl -}}
{{- include "common.tplvalues.render" (dict "value" .Values.baseUrl "context" .) -}}
{{- else if and .Values.ingress.enabled .Values.ingress.hosts -}}
{{- $host := (first .Values.ingress.hosts).host -}}
{{- printf "%s://%s" (ternary "https" "http" (not (empty .Values.ingress.tls))) $host -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified postgres name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "omnigent.postgres.fullname" -}}
{{- $name := default "postgres" .Values.postgres.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "omnigent.database.host" -}}
{{- ternary (include "omnigent.postgres.fullname" .) .Values.database.host .Values.postgres.enabled -}}
{{- end -}}

{{- define "omnigent.database.port" -}}
{{- ternary "5432" (toString .Values.database.port) .Values.postgres.enabled -}}
{{- end -}}

{{- define "omnigent.database.user" -}}
{{- if .Values.postgres.enabled -}}
{{- default "postgres" .Values.postgres.auth.username -}}
{{- else -}}
{{- .Values.database.username -}}
{{- end -}}
{{- end -}}

{{- define "omnigent.database.name" -}}
{{- ternary .Values.postgres.auth.database .Values.database.database .Values.postgres.enabled -}}
{{- end -}}

{{/*
Get the name of the secret containing the DB password
*/}}
{{- define "omnigent.database.secretName" -}}
{{- if .Values.postgres.enabled -}}
{{- default (include "omnigent.postgres.fullname" .) .Values.postgres.auth.existingSecret -}}
{{- else if .Values.database.existingSecret.name -}}
{{- .Values.database.existingSecret.name -}}
{{- else -}}
{{- printf "%s-db-password" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Get the key inside the secret containing the DB user's password
*/}}
{{- define "omnigent.database.secretKey" -}}
{{- if and .Values.postgres.enabled .Values.postgres.auth.existingSecret -}}
{{- default "postgres-password" .Values.postgres.auth.secretKeys.adminPasswordKey -}}
{{- else if and (not .Values.postgres.enabled) .Values.database.existingSecret.name -}}
{{- .Values.database.existingSecret.key -}}
{{- else -}}
{{- "postgres-password" -}}
{{- end -}}
{{- end -}}

{{/*
The SQLAlchemy database URL. The password isn't part of it; libpq reads it from the PGPASSWORD environment variable,
which avoids having to URL-encode it.
*/}}
{{- define "omnigent.database.url" -}}
{{- $url := printf "postgresql+psycopg://%s@%s:%s/%s" (include "omnigent.database.user" .) (include "omnigent.database.host" .) (include "omnigent.database.port" .) (include "omnigent.database.name" .) -}}
{{- if .Values.database.options -}}
{{- $url = printf "%s?%s" $url .Values.database.options -}}
{{- end -}}
{{- $url -}}
{{- end -}}

{{/*
The namespace of the managed sandbox runner pods. Same default as the server.
*/}}
{{- define "omnigent.sandbox.namespace" -}}
{{- dig "sandbox" "kubernetes" "namespace" "omnigent-sandboxes" .Values.config -}}
{{- end -}}

{{/*
The service account of the managed sandbox runner pods. Same default as the server.
*/}}
{{- define "omnigent.sandbox.serviceAccountName" -}}
{{- dig "sandbox" "kubernetes" "service_account" "omnigent-runner" .Values.config -}}
{{- end -}}

{{/*
Whether to create the RBAC for managed sandboxes. Only the `kubernetes` and `agent_sandbox` providers use the Kubernetes API.
*/}}
{{- define "omnigent.sandbox.rbacEnabled" -}}
{{- if .Values.sandbox.rbac.create -}}
{{- $provider := dig "sandbox" "provider" "" .Values.config -}}
{{- if not (has $provider (list "kubernetes" "agent_sandbox")) -}}
{{- fail (printf "sandbox.rbac.create requires config.sandbox.provider to be `kubernetes` or `agent_sandbox`, got %q" $provider) -}}
{{- end -}}
true
{{- end -}}
{{- end -}}

{{/*
The server config. Defaults `sandbox.server_url` to the in-cluster URL of this release's service.
*/}}
{{- define "omnigent.config" -}}
{{- $config := deepCopy .Values.config -}}
{{- if and (hasKey $config "sandbox") (kindIs "map" $config.sandbox) (not (hasKey $config.sandbox "server_url")) -}}
{{- $_ := set $config.sandbox "server_url" (printf "http://%s.%s.svc:%v" (include "common.names.fullname" .) .Release.Namespace .Values.service.port) -}}
{{- end -}}
{{- toYaml $config -}}
{{- end -}}
