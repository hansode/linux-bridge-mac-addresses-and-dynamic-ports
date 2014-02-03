# Linux bridge: MAC addresses and dynamic ports

via http://backreference.org/2010/07/28/linux-bridge-mac-addresses-and-dynamic-ports/

> Scenario: KVM virtualization host running several bridged guests. The host has a bridge interface br0 that starts out containing only eth0, and other interfaces are dynamically added and removed from the bridge as guests are started and stopped.
> The problem is, the host seems to randomly suffer some loss of connectivity (from a few to 30-40 seconds) when some guest is started or stopped. Initially one might think of something related to STP, but it turns out that it is disabled (and even then, ports appearing or disappearing should not affect existing ports).
>
> What happens here is that, when a new guest is started, a tap interface is created and enslaved to the bridge (the tap interface is usually connected to the guest's own ethernet interface).

> Fortunately, there is a way to ensure that the bridge's MAC address is fixed and never changes, thus entirely avoiding the problem.

## System Requirements

+ [Vagrant](http://www.vagrantup.com/downloads.html)
+ [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
+ Vagrant Base Box for CentOS-6

## Guest Specification

| node   | linux bridge        | base eth1                  | added/removed nic |
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
