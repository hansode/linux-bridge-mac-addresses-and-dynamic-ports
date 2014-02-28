custom-kmod-bridge
==================

+ CentOS-6.4 x86_64
+ kernel-2.6.32-358.el6.src.rpm

Verification
------------

```
$ make
```

```
$ lsmod

$ sudo rmmod  bridge
$ lsmod

$ sudo insmod bridge.ko
$ lsmod
```

```
$ sudo tail -F /var/log/messages
Feb 28 18:20:40 node03 kernel: brtap: if (br->flags & BR_SET_MAC_ADDR) # br->flags (1) & BR_SET_MAC_ADDR (1)
Feb 28 18:22:20 node03 kernel: device eth1 entered promiscuous mode
Feb 28 18:22:20 node03 kernel: brtap2: if (br->flags & BR_SET_MAC_ADDR) # br->flags (0) & BR_SET_MAC_ADDR (1)
Feb 28 18:22:41 node03 kernel: device eth1 left promiscuous mode
Feb 28 18:22:41 node03 kernel: brtap2: port 1(eth1) entering disabled state
Feb 28 18:22:41 node03 kernel: brtap2: if (br->flags & BR_SET_MAC_ADDR) # br->flags (0) & BR_SET_MAC_ADDR (1)
Feb 28 18:22:53 node03 kernel: device eth1 entered promiscuous mode
Feb 28 18:22:53 node03 kernel: brtap2: if (br->flags & BR_SET_MAC_ADDR) # br->flags (0) & BR_SET_MAC_ADDR (1)
```
