{{- define "kafka-topics.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kafka-topics.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "kafka-topics.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "kafka-topics.labels" -}}
app.kubernetes.io/name: {{ include "kafka-topics.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "kafka-topics.topicResourceName" -}}
{{- $topic := .topicName -}}
{{- $safe := $topic | lower | replace "." "-" | replace "_" "-" | replace " " "-" -}}
{{- printf "%s-%s" ($safe | trunc 45 | trimSuffix "-") ($topic | sha256sum | trunc 8) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
