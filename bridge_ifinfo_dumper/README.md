bridge_ifinfo_dumper
====================

System Requirements
-------------------

+ CentOS-6.4
+ bridge-utils 1.2

Usage
-----

```
$ make
$ sudo insmod bridge_ifinfo_dumper.ko
$ sudo rmmod  bridge_ifinfo_dumper
```

Scenario Testing
----------------

### Terminal-A

```
$ sudo tail -F /var/log/messages
```

### Terminal-B

1: Setup linux bridge

```
$ sudo brctl addbr brtest0
$ cat /sys/class/net/brtest0/bridge/bridge_id
```

2: Setup tap interface

```
$ sudo tunctl -t   taptest0
```

3: add tap interface to bridge interface

```
$ sudo brctl addif brtest0 taptest0
```

4: delete tap interface from bridge interface

```
$ sudo brctl delif brtest0 taptest0
```

5: set static mac address to bridge interface

```
$ sudo ip link set brtest0 address fe:fe:fe:fe:fe:fe
$ cat /sys/class/net/brtest0/bridge/bridge_id
```

6: re-add tap interface to bridge interface

```
$ sudo brctl addif brtest0 taptest0
```

7: re-delete tap interface from bridge interface

```
$ sudo brctl delif brtest0 taptest0
```

8: Tear down tap interface

```
$ sudo tunctl -d   taptest0
```

9: Tear down bridge interface

```
$ sudo brctl delbr brtest0
```

Verification Results
--------------------

### Terminal-A

```
$ sudo tail -F /var/log/messages
Mar  3 14:30:43 vagrant-centos6 kernel: device taptest0 entered promiscuous mode
Mar  3 14:30:43 vagrant-centos6 kernel: *brtest0: flags:(0)

Mar  3 14:30:55 vagrant-centos6 kernel: device taptest0 left promiscuous mode
Mar  3 14:30:55 vagrant-centos6 kernel: brtest0: port 1(taptest0) entering disabled state
Mar  3 14:30:55 vagrant-centos6 kernel: *brtest0: flags:(0)

Mar  3 14:31:23 vagrant-centos6 kernel: device taptest0 entered promiscuous mode
Mar  3 14:31:23 vagrant-centos6 kernel: *brtest0: flags:(1)

Mar  3 14:31:26 vagrant-centos6 kernel: device taptest0 left promiscuous mode
Mar  3 14:31:26 vagrant-centos6 kernel: brtest0: port 1(taptest0) entering disabled state
Mar  3 14:31:26 vagrant-centos6 kernel: *brtest0: flags:(1)
```

### Terminal-B

```
$ sudo brctl addbr brtest0
$ cat /sys/class/net/brtest0/bridge/bridge_id
8000.000000000000
$ sudo tunctl -t   taptest0

$ sudo brctl addif brtest0 taptest0
$ sudo brctl delif brtest0 taptest0

$ sudo ip link set brtest0 address fe:fe:fe:fe:fe:fe
$ cat /sys/class/net/brtest0/bridge/bridge_id
8000.fefefefefefe

$ sudo brctl addif brtest0 taptest0
$ sudo brctl delif brtest0 taptest0

$ sudo tunctl -d   taptest0
$ sudo brctl delbr brtest0
```
