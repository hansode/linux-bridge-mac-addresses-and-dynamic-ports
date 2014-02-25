# Linux bridge: MAC addresses and dynamic ports

via [Linux bridge: MAC addresses and dynamic ports](http://backreference.org/2010/07/28/linux-bridge-mac-addresses-and-dynamic-ports/)

> Scenario: KVM virtualization host running several bridged guests. The host has a bridge interface br0 that starts out containing only eth0, and other interfaces are dynamically added and removed from the bridge as guests are started and stopped.
> The problem is, the host seems to randomly suffer some loss of connectivity (from a few to 30-40 seconds) when some guest is started or stopped. Initially one might think of something related to STP, but it turns out that it is disabled (and even then, ports appearing or disappearing should not affect existing ports).
>
> What happens here is that, when a new guest is started, a tap interface is created and enslaved to the bridge (the tap interface is usually connected to the guest's own ethernet interface).

> Fortunately, there is a way to ensure that the bridge's MAC address is fixed and never changes, thus entirely avoiding the problem.

via [Set a stable & high MAC addr for guest TAP devices on host](https://www.redhat.com/archives/libvir-list/2010-July/msg00450.html)

> A Linux software bridge will assume the MAC address of the enslaved interface with the numerically lowest MAC addr.
> When the bridge changes MAC address there is a period of network blackout, so a change should be avoided.
> The kernel gives TAP devices a completely random MAC address.
> Occassionally the random TAP device MAC is lower than that of the physical interface (eth0, eth1etc) that is enslaved, causing the bridge to change its MAC.

via [Understanding Linux Network Internals](http://it-ebooks.info/book/2195/)

[net/bridge/br_stp_if.c br_stp_recalculate_bridge_id](https://github.com/torvalds/linux/blob/v2.6.32/net/bridge/br_stp_if.c#L209-L230):

> Bridge MAC address:
>
> The lowest MAC address among the ones configured on the enslaved devices is selected.
> The selection is done with br_stp_recalculate_bridge_id anytime a new bridge port is created or deleted, and when an enslaved device changes its MAC address.

[net/bridge/br_ioctl.c br_dev_ioctl](https://github.com/torvalds/linux/blob/v2.6.32/net/bridge/br_ioctl.c#L400-L416):

> The bridge MAC address dev_addr is cleared because it will be derived by the MAC addresses configured on its enslaved devices with br_stp_recalculate_bridge_id.
> For the same reason, the drive does not provide a set_mac_addr function.

via [linux-2.6.32 source code](https://github.com/torvalds/linux/tree/v2.6.32)

[net/bridge/br_stp_if.c#L217-L219](https://github.com/torvalds/linux/blob/v2.6.32/net/bridge/br_stp_if.c#L217-L219):

```
 	/* user has chosen a value so keep it */
	if (br->flags & BR_SET_MAC_ADDR)
		return;
```

[net/bridge/br_private.h#L101-L102](https://github.com/torvalds/linux/blob/v2.6.32/net/bridge/br_private.h#L101-L102):

```
	unsigned long			flags;
#define BR_SET_MAC_ADDR		0x00000001
```

# Issue: bridge's unstable MAC address & TAP's low MAC address

```
                <-----------+
                  lower     |
                      area  |
00:00:00:00:00 .-----o------o----. ff:ff:ff:ff:ff:ff
                 tapxxx   brtap(unstable)
```

## System Requirements

+ [Vagrant](http://www.vagrantup.com/downloads.html)
+ [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
+ Vagrant Base Box for CentOS-6

## Minimal Testing Scenario

1: Setup linux bridge

```
$ sudo brctl addbr brtap
$ cat /sys/class/net/brtap/address
```

2: Setup tap interface

```
$ sudo tunctl -t         tapxxx
```

3: Compare current MAC address and previous MAC address

```
$ sudo brctl addif brtap tapxxx
$ cat /sys/class/net/brtap/address
```

4: Compare current MAC address and previous MAC address

```
$ sudo brctl delif brtap tapxxx
$ cat /sys/class/net/brtap/address
```

5: Tear down tap interface

```
$ sudo tunctl -d         tapxxx
```

## Guest Specification

| node   | linux bridge        | real slave interface       | slave interface   |
|:-------|:--------------------|:---------------------------|:------------------|
| node01 | `brtap` unfixed MAC | none                       | `tapxxx` random   |
| node02 | `brtap` unfixed MAC | `eth1` random              | `tapxxx` random   |
| node03 | `brtap`   fixed MAC | `eth1` random              | `tapxxx` random   |
| node04 | `brtap` unfixed MAC | `eth1` `00:00:00:00:00:01` | `tapxxx` random   |
| node05 | `brtap` unfixed MAC | `eth1` `fe:ff:ff:ff:ff:ff` | `tapxxx` random   |
| node06 | `brtap` unfixed MAC | `eth1` `80:00:00:00:00:00` | `tapxxx` random   |

## Test Result

| node   | total  | changed |     % |
|:-------|:-------|--------:|------:|
| node01 |  1,000 |  1,001  |  100% |
| node02 |  1,000 |    376  |   37% |
| node03 |  1,000 |      0  |    0% |
| node04 |  1,000 |      0  |    0% |
| node05 |  1,000 |  1,000  |  100% |
| node06 |  1,000 |    476  |   47% |

## Usage

```
$ vagrant up
```

### Run testing script

```
$ vagrant ssh <node> -c "sudo /vagrant/vif-adddel.sh"
```
