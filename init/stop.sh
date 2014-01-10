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

if pgrep -f flashpolicyd.py &> /dev/null ; then
    echo "Stopping flashpolicyd.py:"
    pkill -TERM -f flashpolicyd.py
    rm -f /var/lock/subsys/flashpolicyd.py
fi
EOF
