#!/bin/bash

source /etc/mlab/slice-functions

path=$SLICEHOME/build/sbin
logpath=$SLICEHOME/build/ndt
flashpolicyd_log=/var/log/flashpolicyd.log
export PATH=$PATH:$SLICEHOME/build/bin:$SLICEHOME/build/sbin
export LD_LIBRARY_PATH=/home/iupui_ndt/build/lib:$LD_LIBRARY_PATH

[ -f $path/ndtd ] || exit 0
[ -f $path/fakewww ] || exit 0

# Paths to private key and certificate for SSL operation
PRIVATE_KEY=/etc/pki/tls/private/measurement-lab.org.key
SSL_CERT=/etc/pki/tls/certs/measurement-lab.org.crt
TLS_PORT=3010

# Location of web100 variables file
WEB100_VARS=$SLICEHOME/build/ndt/web100_variables

# NOTE: explicityly disabled "--adminview" to avoid calculation error bug:
# https://code.google.com/p/ndt/issues/detail?id=79
WEB100SRV_OPTIONS="-dddddd --log_dir $SLICERSYNCDIR/ --snaplog --tcpdump --cputime
                   --multiple --max_clients=40 --disable_extended_tests
                   -f $WEB100_VARS"
FAKEWWW_OPTIONS=""

# Set SSL flags if private key and certificate exist
if [ -f $PRIVATE_KEY ] && [ -f $SSL_CERT ]; then
    SSL_OPTIONS="--tls_port $TLS_PORT --private_key $PRIVATE_KEY --certificate $SSL_CERT"
    WEB100SRV_OPTIONS="${WEB100SRV_OPTIONS} $SSL_OPTIONS"
fi

if ! pgrep -f ndtd &> /dev/null ; then
    echo "Starting ndtd:"
    # rotate log file before starting
    [ -f $logpath/web100srv.log.1 ] && mv $logpath/web100srv.log.1 $logpath/web100srv.log.2
    [ -f $logpath/web100srv.log   ] && mv $logpath/web100srv.log $logpath/web100srv.log.1
    # ndtd must run as root
    # Load the getnameinfo library to disable all rDNS requests.
    LD_PRELOAD=$SLICEHOME/build/lib/getnameinfo.so \
        nohup $path/ndtd $WEB100SRV_OPTIONS 2>&1 \
            | $SLICEHOME/init/logger.py /var/log/web100srv.debug &
    sleep .5
    pgrep -f ndtd > /var/lock/subsys/ndtd
else
    echo "Already running: ndtd"
fi

if ! pgrep -f fakewww &> /dev/null ; then
    echo "Starting fakewww:"
    nohup $path/fakewww $FAKEWWW_OPTIONS > /dev/null 2>&1 &
    sleep .5
    pgrep -f fakewww > /var/lock/subsys/fakewww
else
    echo "Already running: fakewww"
fi

if ! pgrep -f flashpolicyd.py &> /dev/null ; then
    echo "Starting flashpolicyd.py:"
    # rotate log file before starting
    [ -f $flashpolicyd_log.1 ] && mv $flashpolicyd_log.1 $flashpolicyd_log.2
    [ -f $flashpolicyd_log   ] && mv $flashpolicyd_log $flashpolicyd_log.1
    nohup $SLICEHOME/flashpolicyd.py > /dev/null 2> $flashpolicyd_log &
    sleep .5
    pgrep -f flashpolicyd.py > /var/lock/subsys/flashpolicyd.py
else
    echo "Already running: flashpolicyd.py"
fi

if ! pgrep -f inotify_exporter &> /dev/null ; then
    echo "Starting inotify_exporter:"
    nohup $SLICEHOME/build/bin/inotify_exporter --path /var/spool/iupui_ndt &> /dev/null &
    sleep .5
    pgrep -f inotify_exporter > /var/lock/subsys/inotify_exporter
else
    echo "Already running: inotify_exporter"
fi
