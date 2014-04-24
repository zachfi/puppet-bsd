# Puppet BSD

[![Build Status](https://travis-ci.org/puppetlabs-operations/puppet-bsd.png?branch=master)](https://travis-ci.org/puppetlabs-operations/puppet-bsd)

A Puppet module for managing aspects of BSD.  Currently supported are FreeBSD and OpenBSD.

## Network

Basic network configuration is handled by the `bsd::network` class.  On a host
machine that will use static addressing, first you may wish to configure the
gateway(s).

```Puppet
class { 'bsd::network':
  v4gateway => '10.0.0.1',
  v6gateway => 'fc00::',
}
```

Then you may wish to set an interface address.

```Puppet
bsd::network::interface { 'em0':
  description => 'Primary Interface',
  values      => [ '10.0.0.2/24', 'fc00::b0b/64' ],
}
```

This will do the needful of setting the configuration for setting the interface
address and gateway.




