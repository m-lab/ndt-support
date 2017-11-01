#!/bin/bash

sudo -s <<\EOF
source /etc/mlab/slice-functions

if test -f /var/lock/subsys/ndtd ; then
    echo "Stopping ndtd:"
    kill -KILL `cat /var/lock/subsys/ndtd`
    rm -f /var/lock/subsys/ndtd
fi

if test -f /var/lock/subsys/fakewww ; then
    echo "Stopping fakewww:"
    kill -TERM `cat /var/lock/subsys/fakewww`
    rm -f /var/lock/subsys/fakewww
fi

if test -f /var/lock/subsys/flashpolicyd.py ; then
    echo "Stopping flashpolicyd.py:"
    kill -TERM `cat /var/lock/subsys/flashpolicyd.py`
    rm -f /var/lock/subsys/flashpolicyd.py
fi

if test -f /var/lock/subsys/inotify_exporter ; then
    echo "Stopping inotify_exporter:"
    kill -TERM `cat /var/lock/subsys/inotify_exporter`
    rm -f /var/lock/subsys/inotify_exporter
fi
EOF
