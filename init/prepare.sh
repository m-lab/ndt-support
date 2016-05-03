#!/bin/bash

set -x 
set -e

if [ -z "$SOURCE_DIR" ] ; then
    echo "Expected SOURCE_DIR in environment"
    exit 1
fi
if [ -z "$BUILD_DIR" ] ; then
    echo "Expected BUILD_DIR in environment"
    exit 1
fi

if test -d $BUILD_DIR ; then
    rm -rf $BUILD_DIR/*
fi

# SETUP development environment
yum groupinstall -y 'Development Tools'
yum install -y libpcap libpcap-devel \
               java-1.7-openjdk java-1.7.0-openjdk-devel \
               zlib-devel zlib \
               jansson-devel

# NOTE: only needed when building ndt from svn-source
# pushd $SOURCE_DIR/I2util/
#    ./bootstrap.sh
#    ./configure --prefix=$BUILD_DIR/build
#    make
#    make install
# popd

# NOTE: unpacked from tar-archives by bootstrap.sh
pushd $SOURCE_DIR/web100_userland-1.8
    ./configure --prefix=$BUILD_DIR/build  --disable-gtk2 --disable-gtktest
    make
    make install
popd

# NOTE: unpacked from tar-archives by bootstrap.sh
pushd $SOURCE_DIR/ndt
    export CPPFLAGS="-I$BUILD_DIR/build/include -I$BUILD_DIR/build/include/web100"
    export LDFLAGS="-L$BUILD_DIR/build/lib"
    ./bootstrap
    ./configure --enable-fakewww --prefix=$BUILD_DIR/build
    # Run unit tests on source before making and installing
    make
    make check || (echo "Unit testing of the source code failed." && exit 1)
    make install

    # Applet gets remade if we do this before 'make install'
    # NOTE: call helper script for signing jar
    # NOTE: but, skip for now
    while true; do
        $SOURCE_DIR/init/signedpackage.sh $BUILD_DIR/build/ndt/Tcpbw100.jar
        if [[ $? -eq 0 ]]; then
           break
        fi
        echo "Opening a new shell so that you can sign a newly-produced jar, and/or investigate further."
        echo "When you are done, simply exit the shell, and the package build process will proceed."
        bash
    done
popd

cp -r $SOURCE_DIR/init             $BUILD_DIR/
cp    $SOURCE_DIR/tcpbw100.html    $BUILD_DIR/
cp    $SOURCE_DIR/flashpolicy.xml  $BUILD_DIR/
install -m 0755 $SOURCE_DIR/flashpolicyd.py  $BUILD_DIR/

# NOTE: admin.html is automatically generated and should not be included.
rm -f $BUILD_DIR/build/ndt/admin.html

