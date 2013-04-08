#!/bin/bash

set -e
set -x
# NOTE: to be run within slice support repo.

# pull in any git submodules
if test -f .gitmodules ; then
    git submodule update --init --recursive 
fi

# svn does not have this functionality, so use a script
if test -f svn-submodules ; then
    cat svn-submodules | while read rev repo dir ; do 
        echo "Checking out revision:$rev from $repo"
        svn checkout -r $rev $repo $dir
    done
fi

