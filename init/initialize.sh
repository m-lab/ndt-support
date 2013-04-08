#!/bin/bash

source /etc/mlab/slice-functions
sed -e 's/HOSTNAME/'$(hostname)'/g' tcpbw100.html > $SLICEHOME/build/ndt/tcpbw100.html
