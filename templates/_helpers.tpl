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
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else if .Values.application }}
{{- .Values.application.name | trunc 63 | trimSuffix "-" }}
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
Selector labels.
*/}}
{{- define "quickstart-java-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quickstart-java-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
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
