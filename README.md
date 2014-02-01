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

+ node01
  + a simple linux bridge
+ node02
  + a simple linux bridge with a tap device
+ node03
  + a simple linux bridge fixed MAC address with a tap device

## Usage

```
$ vagrant up
```

### for node01

```
$ vagrant ssh node01 -c "sudo /vagrant/vif-adddel.sh"
```

### for node02

```
$ vagrant ssh node02 -c "sudo /vagrant/vif-adddel.sh"
```

### for node03

```
$ vagrant ssh node03 -c "sudo /vagrant/vif-adddel.sh"
```
