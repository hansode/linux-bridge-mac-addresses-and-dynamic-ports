KERNEL_TREE := /lib/modules/$(shell uname -r)/build

PWD := $(shell pwd)

obj-m := bridge_ifinfo_dumper.o

all:
	$(MAKE) -C $(KERNEL_TREE) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_TREE) M=$(PWD) clean
