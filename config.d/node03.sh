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

# set static mac adress to linux bridge
ip link set ${brname} address $(cat /sys/class/net/${ethname}/address)
