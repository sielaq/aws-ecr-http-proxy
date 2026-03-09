#!/usr/bin/env python3

import subprocess
import sys
import time
import boto3

TOKEN_FILE = "/usr/local/openresty/nginx/token.txt"

ecr = boto3.client("ecr")

while True:
    response = ecr.get_authorization_token()
    token = response["authorizationData"][0]["authorizationToken"]
    if token:
        break
    print("Warn: Unable to get new token, wait and retry!")
    time.sleep(30)

with open(TOKEN_FILE, "w") as f:
    f.write(token)

# Skip reload when called from startup (nginx not running yet)
if "--reload" in sys.argv:
    subprocess.run(["nginx", "-s", "reload"], check=True)
