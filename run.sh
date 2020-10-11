#!/usr/bin/env sh
set -e

# user supplied variables
# AWS_ACCOUNT
# AWS_REGION
# RANCHER_ACCESS_KEY
# RANCHER_SECRET_KEY
# REGISTRY_USERNAME
# REGISTRY_SECRET
# RANCHER_PROJECT_ID
# RANCHER_URL

# generated variables
REGISTRY_SERVER="${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"
REGISTRY_PASSWORD="$(aws ecr get-login-password --region ${AWS_REGION})"
RANCHER_REGISTRY_SECRET_ID_PREFIX="$(echo ${RANCHER_PROJECT_ID} | awk -F':' '{print $2}')"

# registry data
REGISTRY_DATA='{
  "name": "'${REGISTRY_SECRET}'",
  "namespaceId": null,
  "ownerReferences": [],
  "projectId": "'${RANCHER_PROJECT_ID}'",
  "registries": {
    "'${REGISTRY_SERVER}'": {
      "username": "'${REGISTRY_USERNAME}'",
      "password": "'${REGISTRY_PASSWORD}'"
    }
  }
}'

delete_secret () {
  curl --user "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" \
       --silent --output /dev/null \
       --request DELETE \
       ${RANCHER_URL}/v3/project/${RANCHER_PROJECT_ID}/dockerCredentials/${RANCHER_REGISTRY_SECRET_ID_PREFIX}:${REGISTRY_SECRET}
}

http_response () {
  curl --user "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" \
       --write-out '%{http_code}' --silent --output /dev/null \
       --request GET \
       ${RANCHER_URL}/v3/project/${RANCHER_PROJECT_ID}/dockerCredentials/${RANCHER_REGISTRY_SECRET_ID_PREFIX}:${REGISTRY_SECRET}
}

create_secret () {
  curl --user "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" \
       --request POST \
       --header 'Accept: application/json' \
       --header 'Content-Type: application/json' \
       --data "${REGISTRY_DATA}" \
       ${RANCHER_URL}/v3/project/${RANCHER_PROJECT_ID}/dockerCredentials
}

while true; do
  if [ "$(http_response)" == 404 ]; then
    echo 'Secret does not exist, creating...'
    create_secret
    exit
  else
    echo 'Secret exists, deleting...'
    delete_secret
  fi
  sleep 1
done
