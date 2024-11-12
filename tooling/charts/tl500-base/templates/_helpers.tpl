{{- define "ldap_def" -}}
{{- $idp := (lookup "config.openshift.io/v1" "OAuth" "" "cluster").spec.identityProviders -}}
{{- range $idp -}}
{{- if hasKey . "ldap" }}
{{- $ldap := . -}}
{{- $ldap.ldap | toYaml -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.ldap.port" -}}
{{- if $.Values.gitlab.ldap.port -}}
{{ $.Values.gitlab.ldap.port }}
{{- else -}}
{{- $ldap := include "ldap_def" . | fromYaml -}}
{{- $protocol := regexFind "^ldap[s]*" $ldap.url -}}
{{- if eq $protocol "ldap" }}
{{- print "389" -}}
{{- else -}}
{{- print "636" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.ldap.base" -}}
{{- if $.Values.gitlab.ldap.base -}}
{{ $.Values.gitlab.ldap.base }}
{{- else -}}
{{- $ldap := include "ldap_def" . | fromYaml -}}
{{- $ldap_base_dn := regexReplaceAll "^ldap[s]*://" $ldap.url "${1}" | regexFind "/.*" | trimAll "/" | regexFind "^([^?]+)" }}
{{- printf "%s%s" "cn=accounts," $ldap_base_dn -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.ldap.uri" -}}
{{- if $.Values.gitlab.ldap.uri -}}
{{ $.Values.gitlab.ldap.uri }}
{{- else -}}
{{- $ldap := include "ldap_def" . | fromYaml -}}
{{- regexReplaceAll "^ldap[s]*://" $ldap.url "${1}" | regexFind ".*/" | trimAll "/" | regexFind "^([^:]+)" }}
{{- end -}}
{{- end -}}

{{- define "gitlab.ldap.user_filter" -}}
{{ $.Values.gitlab.ldap.user_filter }}
{{- end -}}

{{- define "gitlab.ldap.encryption" -}}
{{- if $.Values.gitlab.ldap.encryption -}}
{{ $.Values.gitlab.ldap.encryption -}}
{{- else -}}
{{ $enc := include "gitlab.ldap.port" . }}
{{- if eq $enc "636" -}}
{{- print "simple_tls" -}}
{{- else -}}
{{- print "plain" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.ldap.secret_name" -}}
{{ $ldap := include "ldap_def" . | fromYaml -}}
{{- print $ldap.bindPassword.name -}}
{{- end -}}

{{- define "gitlab.ldap.bind_password" -}}
{{- if $.Values.gitlab.ldap.password -}}
{{ $.Values.gitlab.ldap.password }}
{{- else -}}
{{- $secret := include "gitlab.ldap.secret_name" . -}}
{{- if (lookup "v1" "Secret" "openshift-config" $secret ) }}
{{- print (lookup "v1" "Secret" "openshift-config" $secret ).data.bindPassword | b64dec -}}
{{- end }}
{{- end }}
{{- end }}

{{- define "gitlab.ldap.bind_dn" -}}
{{- if $.Values.gitlab.ldap.bind_dn -}}
{{ $.Values.gitlab.ldap.bind_dn }}
{{- else -}}
{{- $ldap := include "ldap_def" . | fromYaml -}}
{{- print $ldap.bindDN -}}
{{- end -}}
{{- end -}}

{{- define "tl500.app_domain" -}}
{{- if (lookup "operator.openshift.io/v1" "IngressController" "openshift-ingress-operator" "default") -}}
{{- print (lookup "operator.openshift.io/v1" "IngressController" "openshift-ingress-operator" "default").status.domain -}}
{{- else -}}
{{- print "example.com" -}}
{{- end -}}
{{- end -}}

{{- define "gitlab.root_password" -}}
{{- $password := default (randAlphaNum 10) .Values.gitlab.credentials.root_password }}
{{- if not .Values.gitlab.credentials.root_password }}
{{- $existingSecret := (lookup "v1" "Secret" .Values.gitlab.namespace "gitlab-credentials") }}
{{- if $existingSecret }}
{{- $password = index $existingSecret.data "root_password" | b64dec }}
{{- end -}}
{{- end -}}
{{- print $password -}}
{{- end -}}

{{- define "gitlab.postgres.user" -}}
{{- $username := default (randAlphaNum 10) .Values.gitlab.credentials.postgres_user }}
{{- if not .Values.gitlab.credentials.postgres_user }}
{{- $existingSecret := (lookup "v1" "Secret" .Values.gitlab.namespace "gitlab-credentials") }}
{{- if $existingSecret }}
{{- $username = index $existingSecret.data "postgres_user" | b64dec }}
{{- end -}}
{{- end -}}
{{- print $username -}}
{{- end -}}

{{- define "gitlab.postgres.password" -}}
{{- $password := default (randAlphaNum 10) .Values.gitlab.credentials.postgres_password }}
{{- if not .Values.gitlab.credentials.postgres_password }}
{{- $existingSecret := (lookup "v1" "Secret" .Values.gitlab.namespace "gitlab-credentials") }}
{{- if $existingSecret }}
{{- $password = index $existingSecret.data "postgres_password" | b64dec }}
{{- end -}}
{{- end -}}
{{- print $password -}}
{{- end -}}

{{- define "gitlab.postgres.admin_password" -}}
{{- $password := default (randAlphaNum 10) .Values.gitlab.credentials.postgres_admin_password }}
{{- if not .Values.gitlab.credentials.postgres_admin_password }}
{{- $existingSecret := (lookup "v1" "Secret" .Values.gitlab.namespace "gitlab-credentials") }}
{{- if $existingSecret }}
{{- $password = index $existingSecret.data "postgres_admin_password" | b64dec }}
{{- end -}}
{{- end -}}
{{- print $password -}}
{{- end -}}
