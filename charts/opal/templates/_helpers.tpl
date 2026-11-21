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
Connection details of a database. Call with (dict "db" .Values.opal.database.<data|ids> "context" $).
When the bundled postgres is enabled, its connection details are used for all databases.
*/}}
{{- define "opal.database.host" -}}
{{- ternary (include "opal.postgresql.fullname" .context) .db.host .context.Values.postgres.enabled -}}
{{- end -}}

{{- define "opal.database.port" -}}
{{- ternary 5432 .db.port .context.Values.postgres.enabled -}}
{{- end -}}

{{- define "opal.database.user" -}}
{{- if .context.Values.postgres.enabled -}}
{{- default "postgres" .context.Values.postgres.auth.username -}}
{{- else -}}
{{- .db.username -}}
{{- end -}}
{{- end -}}

{{- define "opal.database.name" -}}
{{- ternary .context.Values.postgres.auth.database .db.database .context.Values.postgres.enabled -}}
{{- end -}}

{{/*
secretKeyRef (name + key) of a database password.
Call with (dict "db" .Values.opal.database.<data|ids> "key" "<key in the credentials secret>" "context" $).
*/}}
{{- define "opal.database.secretKeyRef" -}}
{{- $pg := .context.Values.postgres -}}
{{- if $pg.enabled -}}
name: {{ default (include "opal.postgresql.fullname" .context) (tpl $pg.auth.existingSecret .context) }}
key: {{ ternary (default "postgres-password" $pg.auth.secretKeys.adminPasswordKey) "postgres-password" (not (empty $pg.auth.existingSecret)) }}
{{- else -}}
{{- include "opal.credentials.secretKeyRef" (dict "existingSecret" .db.existingSecret "key" .key "context" .context) }}
{{- end -}}
{{- end -}}

{{/*
Name of the Secret holding all passwords managed by the chart
*/}}
{{- define "opal.credentials.secretName" -}}
{{- printf "%s-credentials" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
secretKeyRef (name + key) for a password which is either read from a user-provided existing secret or from the
chart-managed credentials secret. Call with (dict "existingSecret" <existingSecret values> "key" "<key>" "context" $).
*/}}
{{- define "opal.credentials.secretKeyRef" -}}
{{- if .existingSecret.name -}}
name: {{ tpl .existingSecret.name .context }}
key: {{ .existingSecret.key }}
{{- else -}}
name: {{ include "opal.credentials.secretName" .context }}
key: {{ .key }}
{{- end -}}
{{- end -}}

{{/*
YAML list of the entries of the chart-managed credentials secret. Each entry has a `key` and either a `value`,
a `required` error message, or neither, in which case a random password is generated.
*/}}
{{- define "opal.credentials.entries" -}}
{{- $entries := list -}}
{{- with .Values.opal.auth.administrator -}}
{{- if not .existingSecret.name -}}
{{- $entries = append $entries (dict "key" "opal-administrator-password" "value" .password) -}}
{{- end -}}
{{- end -}}
{{- range $user := list "administrator" "manager" "user" -}}
{{- $auth := get $.Values.rock.auth $user -}}
{{- if not $auth.existingSecret.name -}}
{{- $entries = append $entries (dict "key" (printf "rock-%s-password" $user) "value" $auth.password) -}}
{{- end -}}
{{- end -}}
{{- if not .Values.postgres.enabled -}}
{{- range $db := list "data" "ids" -}}
{{- $cfg := get $.Values.opal.database $db -}}
{{- if not $cfg.existingSecret.name -}}
{{- $entries = append $entries (dict "key" (printf "%s-db-password" $db) "value" $cfg.password "required" (printf "opal.database.%s.password or opal.database.%s.existingSecret.name must be set when postgres.enabled=false" $db $db)) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- toYaml $entries -}}
{{- end -}}

{{/*
Checksum over the chart-managed credentials, used to restart the pods when a password changes
*/}}
{{- define "opal.credentials.checksum" -}}
{{- include (print .Template.BasePath "/credentials-secret.yaml") . | sha256sum -}}
{{- end -}}

{{- define "opal.rock-hosts" -}}
{{- $rockName := printf "%s-rock" (include "common.names.fullname" .) -}}
{{- $rock := list -}}
{{- range int .Values.rock.replicaCount | until -}}
{{- $rock = printf "%s-%d.%s-headless:%d" $rockName . $rockName (int $.Values.rock.service.port) | append $rock -}}
{{- end -}}
{{- join "," $rock -}}
{{- end -}}

{{- define "opal.opal.ingress-hosts" -}}
{{- $hosts := list -}}
{{- range .Values.opal.ingress.hosts -}}
{{- $hosts = printf "%s" .host | append $hosts -}}
{{- end -}}
{{- join "," $hosts -}}
{{- end -}}

{{/*
Public URL of Opal derived from the first Ingress host. Uses https if that host is listed in the Ingress TLS config.
*/}}
{{- define "opal.opal.public-url" -}}
{{- $host := (first .Values.opal.ingress.hosts).host -}}
{{- $scheme := "http" -}}
{{- range .Values.opal.ingress.tls -}}
{{- if has $host .hosts -}}
{{- $scheme = "https" -}}
{{- end -}}
{{- end -}}
{{- printf "%s://%s" $scheme $host -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "opal.opal.serviceAccountName" -}}
{{- if .Values.opal.serviceAccount.create }}
{{- default (printf "%s-opal" (include "common.names.fullname" .)) .Values.opal.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.opal.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "opal.rock.serviceAccountName" -}}
{{- if .Values.rock.serviceAccount.create }}
{{- default (printf "%s-rock" (include "common.names.fullname" .)) .Values.rock.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.rock.serviceAccount.name }}
{{- end }}
{{- end }}
