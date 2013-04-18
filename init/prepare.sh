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
yum install -y libpcap libpcap-devel eclipse-ecj libgcj \
               libgcj-devel java-1.5.0-gcj java-1.5.0-gcj-devel

# build I2util library for NDT
pushd $SOURCE_DIR/I2util/
    ./bootstrap.sh 
    ./configure --prefix=$BUILD_DIR/build
    make
    make install
popd 

# TODO: replace with web100 in git
rm -rf web100_userland-1.8*
wget http://www.web100.org/download/userland/version1.8/web100_userland-1.8.tar.gz
tar -C $SOURCE_DIR -zxvf web100_userland-1.8.tar.gz 
pushd $SOURCE_DIR/web100_userland-1.8
    ./configure --prefix=$BUILD_DIR/build  --disable-gtk2 --disable-gtktest
    make
    make install
popd

# build NDT
pushd $SOURCE_DIR/ndt
    ./bootstrap 
    export CPPFLAGS="-I$BUILD_DIR/build/include -I$BUILD_DIR/build/include/web100"
    export LDFLAGS="-L$BUILD_DIR/build/lib"
    ./configure --prefix=$BUILD_DIR/build --with-I2util=$BUILD_DIR/build/.
    make || :  # this will break b/c the java Applet and janalyze need special treatment..
    pushd Applet
        javac -source 1.4 *.java 
    popd
    pushd janalyze
        make JAVACFLAGS="-source 1.5"
    popd
    make install   # should not break now b/c of the earlier steps 
popd

cp -r $SOURCE_DIR/init           $BUILD_DIR/
cp    $SOURCE_DIR/tcpbw100.html  $BUILD_DIR/
# NOTE: admin.html is automatically generated and should not be included.
rm -f $BUILD_DIR/build/ndt/admin.html

