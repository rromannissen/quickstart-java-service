{{/*
Chart name, truncated to 63 characters.
*/}}
{{- define "quickstart-java-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name. Uses release name + chart name, truncated to 63 characters.
If release name already contains the chart name, avoid duplication.
*/}}
{{- define "quickstart-java-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- regexReplaceAll "-+" (regexReplaceAll "[^a-z0-9-]" (.Values.fullnameOverride | lower) "-") "-" | trimPrefix "-" | trunc 63 | trimSuffix "-" }}
{{- else if .Values.application }}
{{- regexReplaceAll "-+" (regexReplaceAll "[^a-z0-9-]" (.Values.application.name | lower) "-") "-" | trimPrefix "-" | trunc 63 | trimSuffix "-" }}
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
Chart label value (name + version).
*/}}
{{- define "quickstart-java-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Standard labels.
*/}}
{{- define "quickstart-java-service.labels" -}}
helm.sh/chart: {{ include "quickstart-java-service.chart" . }}
{{ include "quickstart-java-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- include "quickstart-java-service.konveyorLabels" . }}
{{- end }}

{{/*
Konveyor metadata labels (conditional).
*/}}
{{- define "quickstart-java-service.konveyorLabels" -}}
{{- if .Values.application }}
{{- if .Values.application.owner }}
konveyor.io/owner: {{ .Values.application.owner | quote }}
{{- end }}
{{- if .Values.application.businessService }}
konveyor.io/business-service: {{ .Values.application.businessService | quote }}
{{- end }}
{{- if .Values.application.archetypes }}
konveyor.io/archetype: {{ first .Values.application.archetypes | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Konveyor metadata annotations (conditional).
*/}}
{{- define "quickstart-java-service.konveyorAnnotations" -}}
{{- if .Values.application }}
{{- if .Values.application.repository }}
{{- if .Values.application.repository.url }}
konveyor.io/source-repository: {{ .Values.application.repository.url | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Resolved namespace: namespace value > application.name > "default".
*/}}
{{- define "quickstart-java-service.namespace" -}}
{{- if .Values.namespace }}
{{- regexReplaceAll "-+" (regexReplaceAll "[^a-z0-9-]" (.Values.namespace | lower) "-") "-" | trimPrefix "-" | trunc 63 | trimSuffix "-" }}
{{- else if and .Values.application .Values.application.name }}
{{- regexReplaceAll "-+" (regexReplaceAll "[^a-z0-9-]" (.Values.application.name | lower) "-") "-" | trimPrefix "-" | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- "default" }}
{{- end }}
{{- end }}

{{/*
Full container image reference.
If image.ref is set, use it as-is (for external registries).
Otherwise, build from registry/namespace/fullname:tag.
*/}}
{{- define "quickstart-java-service.image" -}}
{{- if .Values.image.ref }}
{{- .Values.image.ref }}
{{- else }}
{{- $registry := .Values.image.registry }}
{{- $ns := include "quickstart-java-service.namespace" . }}
{{- $name := include "quickstart-java-service.fullname" . }}
{{- $tag := .Values.image.tag | default .Chart.AppVersion }}
{{- printf "%s/%s/%s:%s" $registry $ns $name $tag }}
{{- end }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "quickstart-java-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quickstart-java-service.fullname" . }}
app.kubernetes.io/instance: {{ include "quickstart-java-service.fullname" . }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "quickstart-java-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "quickstart-java-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
