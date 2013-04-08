#!/bin/bash

sudo -s <<\EOF
source /etc/mlab/slice-functions

if pgrep -f ndtd &> /dev/null ; then
    echo "Stopping ndtd:"
    pkill -KILL -f ndtd 
    rm -f /var/lock/subsys/ndtd
fi

if pgrep -f fakewww &> /dev/null ; then
    echo "Stopping fakewww:"
    pkill -TERM -f fakewww
    rm -f /var/lock/subsys/fakewww
fi
EOF
