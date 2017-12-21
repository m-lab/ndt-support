#!/bin/bash
#
# build_rpm.sh uses a canonical build of the m-lab/builder docker image with a
# "production" tag.
#
# So far, other repos using the m-lab/builder docker image depend on images
# hosted in the mlab-sandbox GCR. By using dockerhub we avoid managing ACLs on
# GCR buckets, the need to authenticate with gcloud before using docker commands
# from travis, and make the builder image more easily accessible to the public.
#
# TODO: move build_rpm.sh to the travis repo so it can be re-used by other
# packages.

set -x
set -e

USAGE="$0 'command to run in builder'"
_=${1:?Please provide a command to run: $USAGE}
docker pull measurementlab/builder:production-1.0
docker run -v `pwd`:/root/building \
    measurementlab/builder:production-1.0 bash -c "cd /root/building; $@"
