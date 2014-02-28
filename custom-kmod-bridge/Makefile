KERNEL_TREE := /lib/modules/$(shell uname -r)/build
# KERNEL_TREE := $(HOME)/linux-$(KERN_VERSION)

PWD := $(shell pwd)

#
# Makefile for the IEEE 802.1d ethernet bridging layer.
#

#obj-$(CONFIG_BRIDGE) += bridge.o
#obj-bridge += bridge.o
obj-m := bridge.o

bridge-y	:= br.o br_device.o br_fdb.o br_forward.o br_if.o br_input.o \
			br_ioctl.o br_notify.o br_stp.o br_stp_bpdu.o \
			br_stp_if.o br_stp_timer.o br_netlink.o \
			br_sysfs_if.o br_sysfs_br.o \
			br_netfilter.o br_multicast.o

all:
	$(MAKE) -C $(KERNEL_TREE) M=$(PWD) modules

clean:
	$(MAKE) -C $(KERNEL_TREE) M=$(PWD) clean
