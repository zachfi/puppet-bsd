# Puppet BSD

[![Build Status](https://travis-ci.org/xaque208/puppet-bsd.svg?branch=master)](https://travis-ci.org/xaque208/puppet-bsd)

A Puppet module for managing aspects of BSD.  Currently supported are FreeBSD
and OpenBSD.  In here will be various facts, functions and classes for tuning
and configuring a system.

It is intended that Puppet users of this code use only the classes and facts in
their manifests.  The rest of the code here is simply to support the interface
supplied by the manifests.  Implementing the functions directly is not advised,
as the implementation may shift over time as the module requires.

## Dependencies

This module requires the 'ipaddress' ruby gem to be installed.

```
gem install ipaddress
```

or let Puppet take care:

```Puppet
package { 'ipaddress':
  ensure   => 'present',
  provider => 'gem',
}
```

## Installation

The easiest way to install is to install from the forge.

```
puppet module install zleslie/bsd
```

## Network

Network configuration is handled under the `bsd::network` name space.  Under
this space you will find classes available to configure basic network
configuration items like gateways and static address, to more advanced topics
like `vlan(4)` and `carp(4)` interfaces.

Ideally, this module should support any useful aspect of network configuration,
including things like wireless (AP and client) and static routes.

### Gateways

The gateway can be configured for both router and hosts.

#### host

To configure static addressing on a host, first you may wish to configure the
gateway(s).

```Puppet
class { 'bsd::network':
  v4gateway => '10.0.0.1',
  v6gateway => 'fc00::',
}
```

#### router

To set the upstream gateway on a router system as well as turn on dual stack
forwarding, use the following configuration.

```Puppet
class { 'bsd::network':
  v4gateway    => '1.1.1.1',
  v6gateway    => '2001:b:b::1',
  v4forwarding => true,
  v6forwarding => true,
}
```

### Addressing

Once you have the gateway set, you may wish to set some interface addresses.

```Puppet
bsd::network::interface { 'em0':
  description => 'Primary Interface',
  values      => [ '10.0.0.2/24', 'fc00::b0b/64' ],
}
```

This will do the needful of setting the configuration for setting the interface
address and gateway.

```
NOTE: This only sets the configuration, it does not currently set the running interfaces addresses.
```

### Interfaces

Interface configurations are handled per interface type.  Each supported type
will have an implementation of the library through the user of functions and
expose a manifest to the user for configuration.

#### vlan(4)

To create a `vlan(4)` interface and assign an address to it, use a manifest
like the following.

```Puppet
bsd::network::interface::vlan { 'vlan100':
  id      => '100',
  device  => 'em0',
  address => '10.0.0.1/24',
}
```

It is sometimes desirable to create a VLAN interface without needing to set any
interface addresses on it.  In such a case, simply leave off the address, and
specify the VLAN ID and the device to attach the VLAN to.

```Puppet
bsd::network::interface::vlan { 'vlan100':
  id      => '100',
  device  => 'em0',
}
```

#### carp(4)
```Puppet
bsd::network::interface::carp { "carp0":
  id      => '1',
  address => '10.0.0.1/24',
  carpdev => 'em0',
  pass    => 'TopSecret',
}
```
#### lagg(4) and trunk(4)
```Puppet
bsd::network::interface::trunk { "trunk0":
  interface => ['em0','em1],
  address   => '10.0.0.1/24',
}
```

#### vlan trunks

To configure a set of interfaces as a trunk passing multiple vlans, just leave
the address off of the `trunk(4)` interface and use it as the device for the
`vlan(4)` interface.

```Puppet
bsd::network::interface::trunk { "trunk0":
  interface => ['em0','em1'],
}

bsd::network::interface::vlan { "vlan10":
  id      => '10',
  address => '10.0.10.1/24',
  device  => 'trunk0',
}

bsd::network::interface::vlan { "vlan11":
  id      => '11',
  address => '10.0.11.1/24',
  device  => 'trunk0',
}
```

#### tun tunnel devices

The tun(4) device is supported directly through the `bsd::network::interface`
defined type.

```Puppet
bsd::network::interface { 'tun0':
  values => [
    'up',
    '!/usr/local/bin/openvpn --daemon'
  ]
}
```

#### gif tunnel devices

The gif(4) device is supported directly through the `bsd::network::interface`
defined type. I.e. an IPv6 via IPv4 tunnel could look like:

```Puppet
bsd::network::interface { 'gif0':
  description => 'IPv6 in IPv4 tunnel',
  values      => [
    'tunnel 1.2.3.4 5.6.7.8',
    'inet6 alias 2001:470:6c:bbb::2 2001:470:6c:bbb::1 prefixlen 128',
    '!/sbin/route -n add -inet6 default 2001:470:6c:bbb::1',
  ],
}
```
Note: Ethernet-over-IP modes are not yet supported via this module.

#### gre tunnel devices

The gre(4) device is supported directly through the `bsd::network::interface`
defined type. Prior to make GRE interfaces work, GRE needs to be allowed.
Additionally WCCPv1-style GRE packets can be enabled as well as
MobileIP packets. Example of the bsd::network::gre class below
shows the default values.

```Puppet
class { 'bsd::network::gre':
  allowed  => true,
  wccp     => false,
  mobileip => false,
}

bsd::network::interface { 'gre0':
  description => 'Tunnel interface',
  values      => [
    '172.16.0.1 172.16.0.2 netmask 0xffffffff link0 up',
    'tunnel 1.2.3.4 5.6.7.8',
  ],
}
```

#### pflow interfaces
The pflow(4) device is supported directly through the `bsd::network::interface`
defined type.

```Puppet
bsd::network::interface { 'pflow0':
  description => 'Pflow to collector',
  values      => [
    'flowsrc 1.2.3.4 flowdst 5.6.7.8:1234',
    'pflowproto 10',
  ],
}
```

#### wireless interfaces

There are many networking options for wifi.  See
[http://www.openbsd.org/faq/faq6.html#Wireless](the openbsd documentation) for
more information.

Use the following to connect to a wireless network using WPA.

```Puppet
bsd::network::interface::wifi { 'athn0':
  network_name => 'myssid',
  network_key  => 'mysecretkey',
}
```

#### bridge(4) interfaces
```Puppet
bsd::network::interface::bridge { "bridge0":
  interface => ['em0','em1'],
}
```

## Contributing

Please help make this module better by sending pull requests and filing issues
for feature requests or bugs.  Please adhere to the style and be mindful of the
  tests.

