#!/bin/bash

echo "Setting up the sample environment"

KEPTN_SHIPYARD_CONTROLLER="http://shipyard-controller:8080"
KEPTN_PROJECT="dynatrace"
KEPTN_STAGE="quality-gate"

# Used shipyard
shipyard="$(cat <<-END
apiVersion: "spec.keptn.sh/0.2.0"
kind: "Shipyard"
metadata:
  name: "shipyard-quality-gates"
spec:
  stages:
    - name: "${KEPTN_STAGE}"
END
)"
shipyard_encoded="$(echo "$shipyard" | base64 | tr -d \\n )"

echo "Creating project $KEPTN_PROJECT"
for i in 1 2 3
do
  echo "Attempt $i ..."
  status="$(curl -X POST "${KEPTN_SHIPYARD_CONTROLLER}/v1/project" -H "accept: application/json" -H "Content-Type: application/json"  --write-out %{http_code} -d "{ \"name\": \"${KEPTN_PROJECT}\", \"shipyard\": \"${shipyard_encoded}\"}")"
  if [[ "$status" == 201 ]]; then
    echo "Finished setting up the sample environment"
    exit 0
  fi
  echo "Failed to create Keptn project $KEPTN_PROJECT. HTTP Status code $status"
  sleep "$((5 * $i))"
done

exit 1