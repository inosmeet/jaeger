#!/bin/bash

# Copyright (c) 2024 The Jaeger Authors.
# SPDX-License-Identifier: Apache-2.0
set -euxf -o pipefail
repo="$1"
readme_path="$2"
echo "REPO: ${repo}"
echo "READMEPATH: ${readme_path}"
dockerhub_repository="meetsoni17/$repo"
dockerhub_url="https://hub.docker.com/v2/repositories/$dockerhub_repository/"

if [ ! -f "$readme_path" ]; then
  echo "Warning: the dedicated README file for Docker image $repo was not found at path $readme_path"
  echo "It is recommended to have a dedicated README file for each Docker image"
  exit 1
fi

readme_content=$(<"$readme_path")

set +x

body=$(jq -n \
  --arg full_desc "$readme_content" \
  '{full_description: $full_desc}')

dockerhub_response=$(curl -s -o /dev/null -w "%{http_code}" -X PATCH "$dockerhub_url" \
    -H "Content-Type: application/json" \
    -H "Authorization: JWT $DOCKERHUB_TOKEN" \
    -d "$body")

dockerhub_status_code=$(echo "$dockerhub_response")

if [ $dockerhub_status_code -eq 200 ]; then
  echo "Successfully updated Docker Hub README for $dockerhub_repository"
else
  echo "Failed to update Docker Hub README for $dockerhub_repository with status code $dockerhub_status_code"
  echo "Full response: $dockerhub_response"
fi

set -x