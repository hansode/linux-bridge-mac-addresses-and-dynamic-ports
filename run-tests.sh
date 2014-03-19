#!/bin/bash
#
# requires:
#  bash
#

set -e
set -o pipefail

for i in {1..6}; do
  echo === ${i} ===
  time ./brifinfo-test.sh node0${i}
done

echo "All test passed!!!"
