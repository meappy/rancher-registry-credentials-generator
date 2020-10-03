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

# delete registry secret
curl --user "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" \
     --silent --output /dev/null \
     --request DELETE \
     ${RANCHER_URL}/v3/project/${RANCHER_PROJECT_ID}/dockerCredentials/${RANCHER_REGISTRY_SECRET_ID_PREFIX}:${REGISTRY_SECRET}

# create registry secret
curl --user "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" \
     --request POST \
     --header 'Accept: application/json' \
     --header 'Content-Type: application/json' \
     --data "${REGISTRY_DATA}" \
     ${RANCHER_URL}/v3/project/${RANCHER_PROJECT_ID}/dockerCredentials
