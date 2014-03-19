#!/bin/bash
#
# requires:
#  bash
#
# usage:
#  $0 <node>
#
set -e
set -x
set -o pipefail

node=${1:-node01}

vagrant up ${node}

{
  echo "# /vagrant/vif-adddel.sh"
  vagrant ssh ${node} -c "sudo /vagrant/vif-adddel.sh"
  echo
  echo "# grep brtap: /var/log/messages"
  vagrant ssh ${node} -c "sudo grep brtap: /var/log/messages"
} | tee ${node}.log

vagrant destroy -f ${node}
