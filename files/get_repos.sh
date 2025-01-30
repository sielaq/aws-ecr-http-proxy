#!/bin/sh

REPOS=$(aws ecr describe-repositories \
            --region eu-central-1 \
            --query 'repositories[].repositoryName' \
            --output text)

REPO_AND_TAGS=$(for repo in $REPOS; do
                  aws ecr list-images \
                      --repository-name "$repo" \
                      --region eu-central-1 \
                      --query "{Repository: '$repo', Images: imageIds[*].imageTag}" \
                      --output json
                done)

echo "$REPO_AND_TAGS" | jq -s . > /usr/local/openresty/nginx/html/repos.json