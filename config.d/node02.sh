#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

## functions

function gen_ifcfg_path() {
  local device=${1:-eth0}
  local ifcfg_path=/etc/sysconfig/network-scripts/ifcfg

  echo ${ifcfg_path}-${device}
}

function install_ifcfg_file() {
  local ifname=${1:-eth0}

  tee $(gen_ifcfg_path ${ifname}) </dev/stdin
}

function render_ifcfg_bridge() {
  local ifname=${1:-br0}
  shift; eval local "${@}"

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=Bridge
	$([[ -z "${address}" ]] || echo "MACADDR=${address}")
	BOOTPROTO=none
	ONBOOT=yes
	EOS
}

function render_ifcfg_tap() {
  local ifname=${1:-tap0}
  shift; eval local "${@}"

  cat <<-EOS
	DEVICE=${ifname}
	TYPE=Tap
	$([[ -z "${address}" ]] || echo "MACADDR=${address}")
	BOOTPROTO=none
	ONBOOT=yes
	EOS
}

function install_ifcfg_bridge() {
  local ifname=${1:-br0}
  shift; eval local "${@}"

  render_ifcfg_bridge ${ifname} "${@}" | install_ifcfg_file ${ifname}
}

function install_ifcfg_tap() {
  local ifname=${1:-tap0}
  shift; eval local "${@}"

  render_ifcfg_tap ${ifname} "${@}" | install_ifcfg_file ${ifname}
}

function install_ifcfg_bridge_map() {
  local ifname=${1:-br0}
  shift; eval local "${@}"

  local slave_ifcfg_path=$(gen_ifcfg_path ${slave})
  if [[ ! -f ${slave_ifcfg_path} ]]; then
    return 0
  fi

  local bridge_entry="BRIDGE=${ifname}"
  egrep -q -w "^${bridge_entry}" ${slave_ifcfg_path} || {
    echo ${bridge_entry} >> ${slave_ifcfg_path}
  }
}

##

brname=brtap
ethname=eth1

install_ifcfg_tap                  ${ethname} address=
/etc/init.d/network restart

install_ifcfg_bridge     ${brname}            address=
install_ifcfg_bridge_map ${brname} slave=${ethname}
/etc/init.d/network restart
