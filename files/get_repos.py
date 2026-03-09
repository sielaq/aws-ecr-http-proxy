#!/usr/bin/env python3

import json
import boto3
from concurrent.futures import ThreadPoolExecutor, as_completed

REGION = "eu-central-1"
OUTPUT = "/usr/local/openresty/nginx/html/repos.json"

ecr = boto3.client("ecr", region_name=REGION)


def get_images(repo):
    paginator = ecr.get_paginator("list_images")
    tags = []
    for page in paginator.paginate(repositoryName=repo):
        for image in page["imageIds"]:
            if "imageTag" in image:
                tags.append(image["imageTag"])
    return {"Repository": repo, "Images": tags}


def main():
    paginator = ecr.get_paginator("describe_repositories")
    repos = []
    for page in paginator.paginate():
        for r in page["repositories"]:
            repos.append(r["repositoryName"])

    results = []
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(get_images, repo): repo for repo in repos}
        for future in as_completed(futures):
            results.append(future.result())

    with open(OUTPUT, "w") as f:
        json.dump(results, f)


if __name__ == "__main__":
    main()
