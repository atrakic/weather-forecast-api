#!/usr/bin/env bash

set -e
set -o pipefail

# Deploy web app infrastructure for Linux containers.
#
# Usage:
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/atrakic/azure-webapp-deploy/main/infra/setup.sh | \
#  WEB_APP_NAME=app-$RANDOM IMAGE_NAME=ghcr.io/gh-repository_owner/gh-repo:latest bash -s

WEB_APP_NAME=${WEB_APP_NAME:?"You need to configure the WEB_APP_NAME environment variable; eg. app-$RANDOM"}

# Optionals:
LOCATION_NAME=${LOCATION_NAME:-westeurope}
APP_SERVICE_PLAN_NAME=${APP_SERVICE_PLAN_NAME:-MyPlan}
RESOURCE_GROUP_NAME=${RESOURCE_GROUP_NAME:-rg-$WEB_APP_NAME}
IMAGE_NAME=${IMAGE_NAME:-docker.io/nginx:latest}
SKU_NAME=${SKU_NAME:-S1}
USERNAME=${USERNAME:-}
PASSWORD=${PASSWORD:-}

declare -a ARGS=()
if [[ -n "${USERNAME}" && -n "${PASSWORD}" ]]; then
  ARGS=(-s "${USERNAME}" -w "${PASSWORD}")
  echo az webapp create --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" --plan "$APP_SERVICE_PLAN_NAME" -i "$IMAGE_NAME" "${ARGS[@]}"
fi

# https://learn.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest
az group create --location "$LOCATION_NAME" --name "$RESOURCE_GROUP_NAME"

# https://learn.microsoft.com/en-us/cli/azure/appservice?view=azure-cli-latest
az appservice plan create --name "$APP_SERVICE_PLAN_NAME" --resource-group "$RESOURCE_GROUP_NAME" --sku "$SKU_NAME" --is-linux

# https://learn.microsoft.com/en-us/cli/azure/webapp?view=azure-cli-latest
az webapp create --name "$WEB_APP_NAME" --resource-group "$RESOURCE_GROUP_NAME" --plan "$APP_SERVICE_PLAN_NAME" -i "$IMAGE_NAME" "${ARGS[@]}"
