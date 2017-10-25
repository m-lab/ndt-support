#!/bin/bash

set -x
set -e

USAGE="$0 'command to run in builder'"
_=${1:?Please provide a comment to run: $USAGE}
docker pull measurementlab/builder:production-1.0
docker run -it -v `pwd`:/root/building \
    measurementlab/builder:production-1.0 bash -c "cd /root/building; $@"
