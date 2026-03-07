{{- define "elastic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "elastic.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" (include "elastic.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "elastic.labels" -}}
app.kubernetes.io/name: {{ include "elastic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "elastic.securitySecretName" -}}
{{- if .Values.security.existingSecretName -}}
{{- .Values.security.existingSecretName -}}
{{- else -}}
elastic-credentials
{{- end -}}
{{- end -}}
