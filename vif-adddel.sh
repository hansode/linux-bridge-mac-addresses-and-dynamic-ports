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
 
for i in {0..9}; do
  echo "... ${i}"
  tapname=${tapprefix}${i}
  before_mac=$(showmac)
 
  # setup
  tunctl -t ${tapname} >/dev/null
 
  # main test
  brctl addif    ${brname} ${tapname}
  after_mac=$(showmac); [[ "${before_mac}" == "${after_mac}" ]] || echo changed:addif ${before_mac} ${after_mac}
  brctl delif    ${brname} ${tapname}
  after_mac=$(showmac); [[ "${before_mac}" == "${after_mac}" ]] || echo changed:delif ${before_mac} ${after_mac}
 
  # teardown
  tunctl -d ${tapname} >/dev/null
done
