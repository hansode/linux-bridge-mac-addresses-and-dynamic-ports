#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

# fake eth1
tunctl -t eth1

# add eth1 to bridge
brctl addif brtap eth1
