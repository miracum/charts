{{/*
Create the name of the service account to use
*/}}
{{- define "blaze.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "common.names.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "blaze.customSearchParameters.configMapName" -}}
    {{- if .Values.customSearchParameters.existingConfigmap.name }}
        {{- printf "%s" .Values.customSearchParameters.existingConfigmap.name }}
    {{- else }}
        {{- printf "%s-custom-search-parameters" (include "common.names.fullname" .) }}
    {{- end }}
{{- end -}}

{{- define "blaze.customSearchParameters.configMapKey" -}}
    {{- if .Values.customSearchParameters.existingConfigmap.key }}
        {{- .Values.customSearchParameters.existingConfigmap.key }}
    {{- else }}
        {{- printf "custom-search-parameters.json" }}
    {{- end }}
{{- end -}}
