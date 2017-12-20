#!/bin/bash

sudo -s <<\EOF
source /etc/mlab/slice-functions

if test -f /var/lock/subsys/ndtd ; then
    echo "Stopping ndtd:"
    # Note the minus sign (`-`) before the `cat` command substitution below.
    # This is a special syntax for `kill`, telling it to not just kill the PID,
    # but to kill every process in the PID's process group. This will
    # effectively kill the parent ndtd process, along with any children.
    kill -KILL -$(cat /var/lock/subsys/ndtd)
    rm -f /var/lock/subsys/ndtd
fi

if test -f /var/lock/subsys/fakewww ; then
    echo "Stopping fakewww:"
    kill -TERM $(cat /var/lock/subsys/fakewww)
    rm -f /var/lock/subsys/fakewww
fi

if test -f /var/lock/subsys/flashpolicyd.py ; then
    echo "Stopping flashpolicyd.py:"
    kill -TERM $(cat /var/lock/subsys/flashpolicyd.py)
    rm -f /var/lock/subsys/flashpolicyd.py
fi

if test -f /var/lock/subsys/inotify_exporter ; then
    echo "Stopping inotify_exporter:"
    kill -TERM $(cat /var/lock/subsys/inotify_exporter)
    rm -f /var/lock/subsys/inotify_exporter
fi
EOF
