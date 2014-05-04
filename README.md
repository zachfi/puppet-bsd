# Puppet BSD

[![Build Status](https://travis-ci.org/puppetlabs-operations/puppet-bsd.png?branch=master)](https://travis-ci.org/puppetlabs-operations/puppet-bsd)

A Puppet module for managing aspects of BSD.  Currently supported are FreeBSD and OpenBSD.

## Network

Network configuration is handled under the `bsd::network` name space.  Under
this space you will find classes available to configure basic network
configuration items like gateways and static address, to more advanced topics
like `vlan(4)` and `carp(4)` interfaces.

Ideally, this module should support any useful aspect of network configuration,
including things like wireless (AP and client) and static routes.

### Gateways

The gateway can be configured for both router nodes that may be the gatewayand server nodes.

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
  v4gateway => '1.1.1.1',
  v6gateway => '2001:b:b::1',
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




