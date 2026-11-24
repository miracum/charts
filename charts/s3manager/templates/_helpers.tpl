{{/*
Create the name of the service account to use
*/}}
{{- define "s3manager.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
The name of the secret holding the S3 credentials set inline via `instances[].accessKeyId` and `instances[].secretAccessKey`.
*/}}
{{- define "s3manager.credentialsSecretName" -}}
{{- printf "%s-credentials" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
The name of the ObjectBucketClaim an instance is configured from, if any.
*/}}
{{- define "s3manager.instance.obcName" -}}
{{- dig "objectBucketClaim" "name" "" . -}}
{{- end -}}

{{/*
The display name of an instance. Defaults to the name of its ObjectBucketClaim.
*/}}
{{- define "s3manager.instance.name" -}}
{{- default (include "s3manager.instance.obcName" .) .name -}}
{{- end -}}

{{/*
Whether an instance needs a key pair at all. Instances using IAM or anonymous access don't.
*/}}
{{- define "s3manager.instance.needsKeyPair" -}}
{{- if not (or .useIam (eq (default "" .signatureType) "Anonymous")) -}}
true
{{- end -}}
{{- end -}}

{{/*
Whether an instance's key pair is read from a secret managed outside this chart (existingSecret or an ObjectBucketClaim).
*/}}
{{- define "s3manager.instance.hasExternalKeyPair" -}}
{{- if or (dig "existingSecret" "name" "" .) (include "s3manager.instance.obcName" .) -}}
true
{{- end -}}
{{- end -}}

{{/*
Whether an instance's key pair is set inline and therefore stored in the secret created by this chart.
*/}}
{{- define "s3manager.instance.hasInlineKeyPair" -}}
{{- if and (include "s3manager.instance.needsKeyPair" .) (not (include "s3manager.instance.hasExternalKeyPair" .)) -}}
true
{{- end -}}
{{- end -}}

{{/*
Whether any instance's key pair is set inline.
*/}}
{{- define "s3manager.hasInlineKeyPairs" -}}
{{- range .Values.instances -}}
{{- if include "s3manager.instance.hasInlineKeyPair" . -}}
true
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Validates the configured instances.
*/}}
{{- define "s3manager.validateInstances" -}}
{{- if empty .Values.instances -}}
{{- fail "at least one S3 instance must be configured via `instances`" -}}
{{- end -}}
{{- $names := list -}}
{{- range $index, $instance := .Values.instances -}}
{{- $name := include "s3manager.instance.name" $instance -}}
{{- if not $name -}}
{{- fail (printf "instances[%d].name or instances[%d].objectBucketClaim.name is required" $index $index) -}}
{{- end -}}
{{- if has $name $names -}}
{{- fail (printf "instances[%d].name %q is not unique" $index $name) -}}
{{- end -}}
{{- $names = append $names $name -}}
{{- if and (include "s3manager.instance.obcName" $instance) $instance.endpoint -}}
{{- fail (printf "instances[%d] (%s): endpoint can't be combined with objectBucketClaim, which provides it" $index $name) -}}
{{- end -}}
{{- if include "s3manager.instance.hasInlineKeyPair" $instance -}}
{{- if not (and $instance.accessKeyId $instance.secretAccessKey) -}}
{{- fail (printf "instances[%d] (%s) requires either accessKeyId and secretAccessKey, existingSecret.name, objectBucketClaim.name, useIam=true, or signatureType=Anonymous" $index $name) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
