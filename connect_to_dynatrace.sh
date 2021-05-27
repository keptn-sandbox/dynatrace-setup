#!/bin/bash

echo "===================================================="
echo "Connecting Cloud Automation to Dynatrace Environment"
echo "===================================================="

DT_TENANT=${DT_TENANT:-none}
DT_API_TOKEN=${DT_API_TOKEN:-none}
CA_TENANT=${CA_TENANT:-none}
CA_TOKEN=${CA_TOKEN:-none}
SECRET_NAME=${SECRET_NAME:-none}
HTTP_METHOD=${HTTP_METHOD:-none}

if [[ "$DT_TENANT" == "none" ]]; then
    echo "You have to set DT_TENANT to your Tenant, e.g: https://abc12345.dynatrace.live.com or https://yourdynatracemanaged.com/e/abcde-123123-asdfa-1231231"
    exit 1
fi
if [[ "$DT_API_TOKEN" == "none" ]]; then
    echo "You have to set DT_API_TOKEN to a Token that has read/write configuration, access metrics, log content and capture request data priviliges"
    exit 1
fi

if [[ "$CA_TENANT" == "none" ]]; then
    echo "You have to set CA_TENANT to your Cloud Automation URL, e.g: https://abc12345.cloudautomation.live.com"
    exit 1
fi
if [[ "$CA_API_TOKEN" == "none" ]]; then
    echo "You have to set CA_API_TOKEN to the Cloud Automation Token from your Cloud Automation Tenant"
    exit 1
fi

if [[ "$SECRET_NAME" == "none" ]]; then
    SECRET_NAME="dynatrace"
fi 
if [[ "$HTTP_METHOD" == "none" ]]; then
    HTTP_METHOD="POST"
fi 

echo "Creating/Update secret '${SECRET_NAME}' in Cloud Automation Instance"
curl -X ${HTTP_METHOD} "${CA_TENANT}/api/secrets/v1/secret" \
      -H "accept: application/json" \
      -H "x-token: ${CA_API_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "{ \"data\": { \"DT_TENANT\": \"${DT_TENANT}\", \"DT_API_TOKEN\": \"${DT_API_TOKEN}\", \"KEPTN_API_URL\": \"${CA_TENANT}/api\", \"KEPTN_API_TOKEN\" : \"${CA_API_TOKEN}\", \"KEPTN_BRIDGE_URL\" : \"${CA_TENANT}/bridge\" }, \"name\": \"${SECRET_NAME}\", \"scope\": \"keptn-default\"}"

echo "=========================================================="
echo "Uploading default dynatrace.conf.yaml to dynatrace project"
echo "=========================================================="
dynatraceconfig="$(cat <<-END
spec_version: '0.1.0'
dashboard: query
attachRules:
  tagRule:
  - meTypes:
    - SERVICE
    tags:
    - context: CONTEXTLESS
      key: keptn_service
      value: \$SERVICE
    - context: CONTEXTLESS
      key: keptn_managed
END
)"
dynatraceconfig_encoded="$(echo "$dynatraceconfig" | base64 | tr -d \\n )"
curl -X ${HTTP_METHOD} "${CA_TENANT}/api/configuration-service/v1/project/dynatrace/resource" \
     -H "accept: application/json" \
     -H "x-token: ${CA_API_TOKEN}" \
     -H "Content-Type: application/json" \
     -d "{ \"resources\": [{ \"resourceURI\": \"dynatrace/dynatrace.conf.yaml\", \"resourceContent\": \"${dynatraceconfig_encoded}\" }] }"