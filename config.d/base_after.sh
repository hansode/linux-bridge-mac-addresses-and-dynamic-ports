#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

kmod_name=bridge_ifinfo_dumper
kmod_dir=/vagrant/${kmod_name}
kmod_path=${kmod_dir}/${kmod_name}.ko

if ! lsmod | grep -w ${kmod_name}; then
  if [[ ! -f ${kmod_path} ]]; then
    cd ${kmod_dir}
    make
  fi
  insmod ${kmod_path}
fi
