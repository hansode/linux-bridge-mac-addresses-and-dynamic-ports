#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

# fake eth1
[[ -d /sys/class/net/eth1 ]] || tunctl -t eth1

# add eth1 to bridge
[[ -d /sys/class/net/eth1/brport ]] || brctl addif brtap eth1
