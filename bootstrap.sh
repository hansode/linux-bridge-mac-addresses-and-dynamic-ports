#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

function yum() {
  $(type -P yum) --disablerepo=updates "${@}"
}

addpkgs="
 bridge-utils tunctl
"

if [[ -n "$(echo ${addpkgs})" ]]; then
  yum install -y ${addpkgs}
fi
