SHELL=/bin/bash

all: setup

setup:
	curl -fsSkL https://raw.githubusercontent.com/hansode/ifcfg-setup/master/bin/ifcfg-setup > _node_common.sh
	for i in {1..6}; do cat _node_common.sh _node0$${i}.sh > node0$${i}.sh; chmod +x node0$${i}.sh; done
