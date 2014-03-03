# Linux bridge: MAC addresses and dynamic ports

## Issue: bridge-if's unstable MAC address & slaved-if's low numberd MAC address

```
                <-----------+
                  lower     |
                      area  |
00:00:00:00:00 .-----o------o----. ff:ff:ff:ff:ff:ff
                 slave-if bridge-if(unstable MAC address)
```

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

via [Linux Bridges, care and feeding.](http://blog.tinola.com/?e=4)

> Fixes;
>
> None of these are really appealing.
>
> 1. We could go back to using a VETH device for the host, and using the bond MAC address, and stop putting an IP address on the bridge. We then would need to assign a random MAC to the bond itself (which now seems to work).
> 2. We can create a dummy interface and give it a low numbered MAC address (e.g. starting 00:00) and then connect that to the bridge.
> 3. We can set the MAC address of the primary interface to start 00: so it always is the lowest numbered MAC address. 
>
> We're trying 3 as its the least disruptive. 1 is probably the "proper" way to do it however.

via [Understanding Linux Network Internals](http://it-ebooks.info/book/2195/)

> Bridge MAC address:
>
> The lowest MAC address among the ones configured on the enslaved devices is selected.
> The selection is done with br_stp_recalculate_bridge_id anytime a new bridge port is created or deleted, and when an enslaved device changes its MAC address.

[net/bridge/br_stp_if.c#L209-L230](https://github.com/torvalds/linux/blob/v2.6.32/net/bridge/br_stp_if.c#L209-L230):

```
/* called under bridge lock */
void br_stp_recalculate_bridge_id(struct net_bridge *br)
{
	const unsigned char *br_mac_zero =
			(const unsigned char *)br_mac_zero_aligned;
	const unsigned char *addr = br_mac_zero;
	struct net_bridge_port *p;

	/* user has chosen a value so keep it */
	if (br->flags & BR_SET_MAC_ADDR)
		return;

	list_for_each_entry(p, &br->port_list, list) {
		if (addr == br_mac_zero ||
		    memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)
			addr = p->dev->dev_addr;

	}

	if (compare_ether_addr(br->bridge_id.addr, addr))
		br_stp_change_bridge_id(br, addr);
}
```

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

> The bridge MAC address dev_addr is cleared because it will be derived by the MAC addresses configured on its enslaved devices with br_stp_recalculate_bridge_id.
> For the same reason, the drive does not provide a set_mac_addr function.

[net/bridge/br_device.c#L173-L187](https://github.com/torvalds/linux/blob/v2.6.32/net/bridge/br_device.c#L173-L187):

```
void br_dev_setup(struct net_device *dev)
{
	random_ether_addr(dev->dev_addr);
	ether_setup(dev);

	dev->netdev_ops = &br_netdev_ops;
	dev->destructor = free_netdev;
	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
	dev->tx_queue_len = 0;
	dev->priv_flags = IFF_EBRIDGE;

	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX |
			NETIF_F_NETNS_LOCAL | NETIF_F_GSO;
}
```

## Appendix

### `brctl addif/delif :bridge :device`

[net/bridge/br_ioctl.c#L400-L416](https://github.com/torvalds/linux/blob/v2.6.32/net/bridge/br_ioctl.c#L400-L416):

```
int br_dev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
{
	struct net_bridge *br = netdev_priv(dev);

	switch(cmd) {
	case SIOCDEVPRIVATE:
		return old_dev_ioctl(dev, rq, cmd);

	case SIOCBRADDIF:
	case SIOCBRDELIF:
		return add_del_if(br, rq->ifr_ifindex, cmd == SIOCBRADDIF);

	}

	pr_debug("Bridge does not support ioctl 0x%x\n", cmd);
	return -EOPNOTSUPP;
}
```

### `ip link set :br-if address :macaddr`

[net/bridge/br_device.c#L85-L101](https://github.com/torvalds/linux/blob/v2.6.32/net/bridge/br_device.c#L85-L101):

```
/* Allow setting mac address to any valid ethernet address. */
static int br_set_mac_address(struct net_device *dev, void *p)
{
	struct net_bridge *br = netdev_priv(dev);
	struct sockaddr *addr = p;

	if (!is_valid_ether_addr(addr->sa_data))
		return -EINVAL;

	spin_lock_bh(&br->lock);
	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
	br_stp_change_bridge_id(br, addr->sa_data);
	br->flags |= BR_SET_MAC_ADDR;
	spin_unlock_bh(&br->lock);

	return 0;
}
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
