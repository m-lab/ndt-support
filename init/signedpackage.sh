#!/bin/bash

# NOTE: 
#  signedpackage.sh -- checks for and helps prepare a signed jar file. 
# 
#  1. On first run, signedpackage.sh takes the full path to an unsigned jar,
#     and if not present in /tmp, copies it there and prints a helpful message
#     for what to do next.
#  2. The operator is expected to sign the jar, and restart the build scripts.
#  3. On the second run, signedpackage.sh sees that there is a signed jar in 
#     /tmp, and overwrites the jar given on the command line.
# 
#  The calling script, is expected to include the resulting SIGNED java applet 
#  with the final package.
# 
#  ARGS:
#     - ORIG - full path to original, unsigned jar file.
#              if no file is present in /tmp, then 'cp ORIG /tmp'
#              if file is present in /tmp & signed, then 'cp /tmp/ORIG ORIG'
# 
#  DEPENDENCIES:
#     jarsigner - provided by a java JDK.
#                 NOTE: the GNU java compiler packages do not verify correctly.
# 
#  RETURNS:
#     - 0 - on successfully verifing a signed jar 
#     - 1 - on first run or other error
# 

# TODO: find an automated way. it's a security risk to include the cert on the
# build system; so at the moment, signing the jar requires a manual step.

ORIG=$1
DEST=/tmp/$( basename $ORIG ) 


function prep_jar_as_trusted () {
    # TODO: *surely* there is a more automated way to do this?
    local jarfile=$1
    local tempdir=$( mktemp -d )

    if ! test -r $jarfile ; then
        echo "Error: could not read $jarfile"
        echo "Is is present and readable?"
        rm -rf $tempdir
        return 1
    fi

    # NOTE: move to tempdir, extract jar, modify manifest, and recreate
    pushd $tempdir
        # Extract contents of jar into tempdir;
        if ! jar -xvf $jarfile ; then
            echo "Error: failed to extract $jarfile to $tempdir"
            rm -rf $tempdir
            return 1
        fi

        # Update manifest header to include "Trusted-Library: true"
        # NOTE: this prevents warnings from JRE related to the applet 
        #       containing "trusted" and "untrusted" components.
        # sed: read this as: append "Trusted-Library: true" after line '1'
        sed -e '1 aTrusted-Library: true\r' -i META-INF/MANIFEST.MF 

        # Recreate jar with new manifest: NOTE: overwrite original 'jarfile'.
        if ! jar -cvmf META-INF/MANIFEST.MF $jarfile * ; then
            echo "Error: failed to recreate $jarfile from $tempdir/*"
            rm -rf $tempdir
            return 1
        fi
    popd

    rm -rf $tempdir
    # NOTE: now the jar is ready to be signed.
    return 0
}


function usage () {
    cat <<EOF
    You can sign the jar file with a command like:

        # jarsigner -keystore mlab-java-signing-keystore $DEST mlab

    Once you've done that, verify that the signature is valid with:
    
        # jarsigner -certs -verbose -verify $DEST
    
    Replace $DEST with the signed version and rerun the build scripts.
    This script will automatically detect the signed version and use it.
EOF
}

if ! test -f $DEST ; then
    cp -f $ORIG $DEST
    if ! prep_jar_as_trusted $DEST ; then
        echo "Error: failed to prepare $DEST manifest file."
        exit 1
    fi
    cat <<EOF
NOTICE:
    We did not find a jar at '$DEST'.  If this is the first time you're running
    the build, then this is expected.

    We are copying a new, UNSIGNED jar there for you to SIGN.
EOF
    usage
    exit 1  # only return 0 to confirm that jar was signed
fi

#
# NOTE: jarsigner always returns 0, so we have to parse output.
# NOTE: previous condition would exit:
# NOTE: So here $DEST exits. so, verify that it is now signed.
#
output=$( jarsigner -certs -verify $DEST )
if [[ "jar verified." =~ $output ]] ; then
    # probably ok
    echo "OK: we think this jar is signed: $output"
    echo "NOTICE: overwriting $ORIG with the signed version at $DEST"
    mv -f $DEST $ORIG
    exit 0
else
    # error
    LOG=/tmp/unsigned_jar.log
    jarsigner -certs -verbose -verify $DEST &> $LOG
    cat <<EOF
NOTICE:
    We found $DEST, but it looks unsigned or the signature is bad.
    A more detailed log message is here: $LOG
EOF
    usage
    exit 1
fi
