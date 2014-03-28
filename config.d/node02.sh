#!/bin/bash
#
# description:
#  ifcfg-setup is a utility and framework for /etc/sysconfig/network-scripts/ifcfg-X file management
#
# requires:
#  bash
#  tee, egrep, cat
#
# url:
#  https://github.com/hansode/ifcfg-setup
#

## base

IFCFG_PATH_PREFIX=${IFCFG_PATH_PREFIX:-/etc/sysconfig/network-scripts/ifcfg}
IFCFG_BONDING_CONF_PATH=${IFCFG_BONDING_CONF_PATH:-/etc/modprobe.d/bonding.conf}
IFCFG_VLAN_CONF_PATH=${IFCFG_VLAN_CONF_PATH:-/etc/sysconfig/network}

IFCFG_BOND_PARAMS="
  max_bonds
  num_grat_arp
  num_unsol_na
  miimon
  updelay
  downdelay
  use_carrier
  primary
  lacp_rate
  ad_select
  xmit_hash_policy
  arp_interval
  arp_ip_target
  arp_validate
  fail_over_mac
"

function gen_ifcfg_path() {
  local device=${1:-eth0}
  local ifcfg_path=${IFCFG_PATH_PREFIX}

  echo ${ifcfg_path}-${device}
}

function install_ifcfg_file() {
  local device=${1:-eth0}

  tee $(gen_ifcfg_path ${device}) </dev/stdin
}

function beautify_config_body() {
  cat | egrep -v '^#|^$'

  # ignore exit-code 1 of egrep
  # > $ echo | egrep -v '^#|^$'; echo $?
  # > 1

  ! [[ ${?} == 2 ]]
}

function config_line_in_file() {
  local config_path=${1} entry=${2}

  if [[ ! -f "${config_path}" ]]; then
    : > ${config_path}
  fi
  if ! egrep -q -w "^${entry}" ${config_path}; then
    echo ${entry} >> ${config_path}
  fi
}

function render_ifcfg_network_configuration() {
  unset onboot device type ip mask net bcast gw mac dns1 dns2
  # don't use "shift" here
  [[ ${#} == 0 ]] || eval local "${@}"

  local bootproto=none

  if [[ -n "${ip}" ]]; then
    bootproto=static
  fi

  beautify_config_body <<-EOS
	$([[ -z "${device}" ]] || echo "DEVICE=${device}")
	$([[ -z "${type}"   ]] || echo "TYPE=${type}")
	BOOTPROTO=${bootproto}
	ONBOOT=${onboot:-yes}
	$([[ -z "${mac}"    ]] || echo "MACADDR=${mac}")
	$([[ -z "${dns1}"   ]] || echo "DNS1=${dns1}")
	$([[ -z "${dns2}"   ]] || echo "DNS2=${dns2}")
	EOS

  case ${bootproto} in
    static)
      beautify_config_body <<-EOS
	IPADDR=${ip}
	$([[ -z "${mask}"  ]] || echo "NETMASK=${mask}")
	$([[ -z "${net}"   ]] || echo "NETWORK=${net}")
	$([[ -z "${bcast}" ]] || echo "BROADCAST=${bcast}")
	$([[ -z "${gw}"    ]] || echo "GATEWAY=${gw}")
	EOS
      ;;
  esac
}

# 0:       configure_${type}_conf optional
# 1:    render_ifcfg_${type}      required
# 2:   install_ifcfg_${type}      required
# 3:       map_ifcfg_${type}      optional

## net/ethernet

### 1:

function render_ifcfg_ethernet() {
  local device=${1:-eth0}
  unset onboot ip mask net bcast gw hw dns1 dns2
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_network_configuration "${@}" \
   device=${device} type=Ethernet

  beautify_config_body <<-EOS
	$([[ -z "${hw}" ]] || echo "HWADDR=${hw}")
	EOS
}

### 2:

function install_ifcfg_ethernet() {
  local device=${1:-eth0}
  unset onboot ip mask net bcast gw hw dns1 dns2
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_ethernet ${device} \
   ip=${ip} mask=${mask} net=${net} bcast=${bcast} gw=${gw} \
   hw=${hw} dns1=${dns1} dns2=${dns2} \
   | install_ifcfg_file ${device}
}

## driver/bonding

### 0:

function configure_bonding_conf() {
  local device=${1:-bond0}

  local config_path=${IFCFG_BONDING_CONF_PATH}
  local entry="alias ${device} bonding"

  config_line_in_file ${config_path} "${entry}"
}

### 1:master

function render_ifcfg_bond_master() {
  local device=${1:-bond0}
  unset onboot mode ${IFCFG_BOND_PARAMS}
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  local bond_opts="mode=${mode:-1}"
  local bond_params=${IFCFG_BOND_PARAMS}

  local __param
  for __param in ${bond_params}; do
    eval "
      [[ -z "\$${__param}" ]] || bond_opts=\"\${bond_opts} \${__param}=\$${__param}\"
    "
  done

  render_ifcfg_network_configuration "${@}" \
   device=${device}

  beautify_config_body <<-EOS
	BONDING_OPTS="${bond_opts}"
	EOS
}

### 2:master

function install_ifcfg_bond_master() {
  local device=${1:-bond0}
  unset onboot mode ${IFCFG_BOND_PARAMS}
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_bond_master ${device} \
   mode=${mode} "${@}" \
   | install_ifcfg_file ${device}
}

### 1:slave

function render_ifcfg_bond_slave() {
  local device=${1:-eth0}
  unset onboot master
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_network_configuration "${@}" \
   device=${device}

  beautify_config_body <<-EOS
	MASTER=${master}
	SLAVE=yes
	EOS
}

### 2:slave

function install_ifcfg_bond_slave() {
  local device=${1:-eth0}
  unset onboot master
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_bond_slave ${device} \
   master=${master} \
   | install_ifcfg_file ${device}
}

### 3:

function map_ifcfg_bond() {
  local device=${1:-bond0}
  unset onboot mode master slave ${IFCFG_BOND_PARAMS}
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  configure_bonding_conf    ${device}
  install_ifcfg_bond_master ${device} mode=${mode} "${@}"
  install_ifcfg_bond_slave  ${slave}  master=${device}
}

## net/bridge

### 1:

function render_ifcfg_bridge() {
  local device=${1:-br0}
  unset onboot mac dns1 dns2
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_network_configuration "${@}" \
   device=${device} type=Bridge
}

### 2:

function install_ifcfg_bridge() {
  local device=${1:-br0}
  unset onboot mac dns1 dns2
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_bridge ${device} \
   mac=${mac} dns1=${dns1} dns2=${dns2} \
   | install_ifcfg_file ${device}
}

### 3:

function map_ifcfg_bridge() {
  local device=${1:-br0}
  unset onboot slave
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  install_ifcfg_bridge ${device} "${@}"

  local config_path=$(gen_ifcfg_path ${slave})
  local entry="BRIDGE=${device}"

  config_line_in_file ${config_path} "${entry}"
}

## net/8021q

### 0:

function configure_vlan_conf() {
  local line

  local config_path=${IFCFG_VLAN_CONF_PATH}
  while read line; do
    set ${line}
    config_line_in_file ${config_path} "${line}"
  done < <(beautify_config_body <<-EOS
	VLAN=yes
	VLAN_NAME_TYPE=VLAN_PLUS_VID_NO_PAD
	EOS
  )
}

### 1:

function render_ifcfg_vlan() {
  local device=${1:-vlan1000}
  unset onboot dns1 dns2
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_network_configuration "${@}" \
   device=${device}
}

### 2:

function install_ifcfg_vlan() {
  local device=${1:-vlan1000}
  unset onboot dns1 dns2
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_vlan ${device} \
   dns1=${dns1} dns2=${dns2} \
   | install_ifcfg_file ${device}
}

### 3:

function map_ifcfg_vlan() {
  local device=${1:-vlan1000}
  unset onboot physdev
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  configure_vlan_conf

  install_ifcfg_vlan ${device}

  local config_path=$(gen_ifcfg_path ${device})
  local entry="PHYSDEV=${physdev}"

  config_line_in_file ${config_path} "${entry}"
}

## net/tap

### 1:

function render_ifcfg_tap() {
  local device=${1:-tap0}
  unset onboot dns1 dns2
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_network_configuration "${@}" \
   device=${device} type=Tap
}

### 2:

function install_ifcfg_tap() {
  local device=${1:-tap0}
  unset onboot mac dns1 dns2
  shift; [[ ${#} == 0 ]] || eval local "${@}"

  render_ifcfg_tap ${device} \
   mac=${mac} dns1=${dns1} dns2=${dns2} \
   | install_ifcfg_file ${device}
}

## CLI

function usage() {
  cat <<-EOS
	Usage: ifcfg-setup <command> <device-type> <device-name> [opts...]
	
	commands:
	    render   <device-type> <device-name>  render ifcfg file for debug
	    install  <device-type> <device-name>  install ifcfg file
	    map      <device-type> <device-name>  TODO

	device-type:
	    ethernet
	    bridge
	    vlan
	    tap
	EOS
}

function ifcfg_cli() {
  local cmd=${1} type=${2}; shift 2

  local function=${cmd}_ifcfg_${type}

  declare -f ${function} >/dev/null || { usage; return 1; }
  eval ${function} ${@}
}

if [[ "${BASH_SOURCE[0]##*/}" == "ifcfg-setup" ]]; then
  ifcfg_cli "${@}"
fi

##

brname=brtap
ethname=eth1

install_ifcfg_tap                  ${ethname} mac=
/etc/init.d/network restart

install_ifcfg_bridge     ${brname}            mac=
map_ifcfg_bridge ${brname} slave=${ethname}
/etc/init.d/network restart
