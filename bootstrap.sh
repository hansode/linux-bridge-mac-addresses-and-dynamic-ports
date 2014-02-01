#!/bin/bash
#
# requires:
#  bash
#
set -e
set -x

function yum() {
  $(type -P yum) --disablerepo=updates "${@}"
}

addpkgs="
 bridge-utils tunctl
"

if [[ -n "${addpkgs}" ]]; then
  yum install -y ${addpkgs}
fi
