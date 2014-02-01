#!/bin/bash
#
# requires:
#  bash
#
#set -e
 
LANG=C
LC_ALL=C
 
declare tapprefix=vif$(date +%Y%m%d)
declare brname=brtap
 
function showmac() {
  cat /sys/class/net/${brname}/address
}

total=0
changed=0

for i in {0..9}; do
  total=$((${total} + 1))
  tapname=${tapprefix}
  before_mac=$(showmac)

  printf "... %02d %s" ${i} ${before_mac}
 
  # setup
  tunctl -t ${tapname} >/dev/null
 
  # main test
  brctl addif    ${brname} ${tapname}
  after_mac=$(showmac)
  if [[ "${before_mac}" != "${after_mac}" ]]; then
    printf " [addif] ${before_mac} -> ${after_mac}"
    changed=$((${changed} + 1))
  fi
  brctl delif    ${brname} ${tapname}
  after_mac=$(showmac)
  if [[ "${before_mac}" != "${after_mac}" ]]; then
    printf " [delif] ${before_mac} -> ${after_mac}"
    changed=$((${changed} + 1))
  fi
 
  # teardown
  tunctl -d ${tapname} >/dev/null

  echo
done

echo total:${total} changed:${changed} percentage:$((100 * ${changed} / ${total}))%
