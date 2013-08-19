#!/bin/bash

source /etc/mlab/slice-functions

path=$SLICEHOME/build/sbin
logpath=$SLICEHOME/build/ndt
export PATH=$PATH:$SLICEHOME/build/bin:$SLICEHOME/build/sbin
export LD_LIBRARY_PATH=/home/iupui_ndt/build/lib:$LD_LIBRARY_PATH

[ -f $path/ndtd ] || exit 0
[ -f $path/fakewww ] || exit 0

# NOTE: explicityly disabled "--adminview" to avoid calculation error bug:
# https://code.google.com/p/ndt/issues/detail?id=79
WEB100SRV_OPTIONS="--log_dir $SLICERSYNCDIR/ --snaplog --tcpdump --cputime --multiple --max_clients=40"
FAKEWWW_OPTIONS=""

if ! pgrep -f ndtd &> /dev/null ; then
    echo "Starting ndtd:"
    # rotate log file before starting
    [ -f $logpath/web100srv.log.1 ] && mv $logpath/web100srv.log.1 $logpath/web100srv.log.2
    [ -f $logpath/web100srv.log   ] && mv $logpath/web100srv.log $logpath/web100srv.log.1 
    # ndtd must run as root
    $path/ndtd $WEB100SRV_OPTIONS > /dev/null 2>&1 &
    touch /var/lock/subsys/ndtd
fi

if ! pgrep -f fakewww &> /dev/null ; then
    echo "Starting fakewww:"
    $path/fakewww $FAKEWWW_OPTIONS > /dev/null 2>&1 &
    touch /var/lock/subsys/fakewww
fi

if ! pgrep -f flashpolicyd.py &> /dev/null ; then
    echo "Starting flashpolicyd.py:"
    flashpolicyd.py > /dev/null 2>&1 &
    touch /var/lock/subsys/flashpolicyd.py
fi
