{{/*
Expand the name of the chart.
*/}}
{{- define "hello-world.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hello-world.fullname" -}}
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
{{- define "hello-world.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hello-world.labels" -}}
helm.sh/chart: {{ include "hello-world.chart" . }}
{{ include "hello-world.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hello-world.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hello-world.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hello-world.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hello-world.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
create a default fully qualified name
*/}}
{{- define "vault.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vault.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "vault.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Sets extra injector pod annotations
*/}}
{{- define "injector.annotations" -}}
  {{- if .Values.injector.annotations }}
      annotations:
        {{- $tp := typeOf .Values.injector.annotations }}
        {{- if eq $tp "string" }}
          {{- tpl .Values.injector.annotations . | nindent 8 }}
        {{- else }}
          {{- toYaml .Values.injector.annotations | nindent 8 }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/*
Sets extra statefulset annotations
*/}}
{{- define "vault.statefulSet.annotations" -}}
  {{- if .Values.server.statefulSet.annotations }}
  annotations:
    {{- $tp := typeOf .Values.server.statefulSet.annotations }}
    {{- if eq $tp "string" }}
      {{- tpl .Values.server.statefulSet.annotations . | nindent 4 }}
    {{- else }}
      {{- toYaml .Values.server.statefulSet.annotations | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Set's the replica count based on the different modes configured by user
*/}}
{{- define "vault.replicas" -}}
  {{ if eq .mode "standalone" }}
    {{- default 1 -}}
  {{ else if eq .mode "ha" }}
    {{- .Values.server.ha.replicas | default 3 -}}
  {{ else }}
    {{- default 1 -}}
  {{ end }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "vault.serviceAccount.name" -}}
{{- if .Values.server.serviceAccount.create -}}
    {{ default (include "vault.fullname" .) .Values.server.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.server.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Set's the args for custom command to render the Vault configuration
file with IP addresses to make the out of box experience easier
for users looking to use this chart with Consul Helm.
*/}}
{{- define "vault.args" -}}
  {{ if or (eq .mode "standalone") (eq .mode "ha") }}
          - |
            cp /vault/config/extraconfig-from-values.hcl /tmp/storageconfig.hcl;
            [ -n "${HOST_IP}" ] && sed -Ei "s|HOST_IP|${HOST_IP?}|g" /tmp/storageconfig.hcl;
            [ -n "${POD_IP}" ] && sed -Ei "s|POD_IP|${POD_IP?}|g" /tmp/storageconfig.hcl;
            [ -n "${HOSTNAME}" ] && sed -Ei "s|HOSTNAME|${HOSTNAME?}|g" /tmp/storageconfig.hcl;
            [ -n "${API_ADDR}" ] && sed -Ei "s|API_ADDR|${API_ADDR?}|g" /tmp/storageconfig.hcl;
            [ -n "${TRANSIT_ADDR}" ] && sed -Ei "s|TRANSIT_ADDR|${TRANSIT_ADDR?}|g" /tmp/storageconfig.hcl;
            [ -n "${RAFT_ADDR}" ] && sed -Ei "s|RAFT_ADDR|${RAFT_ADDR?}|g" /tmp/storageconfig.hcl;
            /usr/local/bin/docker-entrypoint.sh vault server -config=/tmp/storageconfig.hcl {{ .Values.server.extraArgs }}
   {{ else if eq .mode "dev" }}
          - |
            /usr/local/bin/docker-entrypoint.sh vault server -dev {{ .Values.server.extraArgs }}
  {{ end }}
{{- end -}}
