#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

brname=brtap
ethname=eth1

# fake eth1
[[ -d /sys/class/net/${ethname} ]] || tunctl -t ${ethname}

# add eth1 to bridge
[[ -d /sys/class/net/${ethname}/brport ]] || brctl addif ${brname} ${ethname}

# set static MAC address
ip link set dev ${ethname} address 80:00:00:00:00:00
