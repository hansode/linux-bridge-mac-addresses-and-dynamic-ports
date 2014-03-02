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

Verification
------------

```
$ sudo tail -F /var/log/messages
```

```
$ sudo brctl addbr brtest0
$ sudo tunctl -t   taptest0
$ sudo brctl addif brtest0 taptest0
$ sudo brctl delif brtest0 taptest0
$ sudo tunctl -d   taptest0
```
