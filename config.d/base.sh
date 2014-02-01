#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

[[ -d /sys/class/net/brtap ]] || brctl addbr brtap
