#!/bin/bash

USAGE="$0 <base64-key> <source file> <dest gcs bucket>"
KEY=${1:?Please provide the base64 encoded service account key: $USAGE}
SOURCE=${2:?Please provide a file to copy: $USAGE}
TARGET=${3:?Please provide bucket and path: $USAGE}

# Add gcloud to PATH.
source "${HOME}/google-cloud-sdk/path.bash.inc"

# Setup the service account key from the environment.
echo $KEY | base64 --decode > /tmp/service-account.json

# Activate the service account credentials. All gcloud actions are performed as
# the service account.
gcloud auth activate-service-account --key-file "/tmp/service-account.json"

# The target bucket must have ACLs that allow WRITE access for the service
# account. You may update the ACL using:
#
#   gsutil acl ch \
#      -u SERVICE_ACCT_NAME@PROJECT.iam.gserviceaccount.com:WRITE gs://BUCKET
#
gsutil cp ${SOURCE} "${TARGET}"
