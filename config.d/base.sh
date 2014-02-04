#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

brname=brtap
ethname=eth1

[[ -d /sys/class/net/${brname} ]] || brctl addbr ${brname}
cat   /sys/class/net/${brname}/address
