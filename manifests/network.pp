# = Class: bsd::network
#
# Configures basic network paramaters on some BSD systems.
#
# == Parameters:
#
# $v4gateway:: A string containing the IPv4 default gateway router.
# $v6gateway:: A string containing the IPv6 default gateway router.
# $v4forwarding:: Boolean to turn on/off IPv4 traffic forwarding functionality.
# $v6forwarding:: Boolean to turn on/off IPv6 traffic forwarding functionality.
#
# = Authors:
#
#   Zach Leslie <xaque208@gmail.com>
#
# Copyright 2013 Puppet Labs
#
class bsd::network (
  $v4gateway    = '',
  $v6gateway    = '',
  $v4forwarding = false,
  $v6forwarding = false,
){

  # Options common to both FreeBSD and OpenBSD
  if $v4forwarding {
    sysctl::value { 'net.inet.ip.forwarding': value => 1 }
  } else {
    sysctl::value { 'net.inet.ip.forwarding': value => 0 }
  }

  if $v6forwarding {
    sysctl::value { 'net.inet6.ip6.forwarding': value => 1 }
  } else {
    sysctl::value { 'net.inet6.ip6.forwarding': value => 0 }
  }

  case $::osfamily {
    'openbsd': {
      # TODO Manage the live state of the route table

      # Manage the /etc/mygate file
      # TODO Sanitize input here
      if $v4gateway != '' and $v6gateway != '' {
        $mygate = [$v4gateway,$v6gateway]
      } elsif $v4gateway != '' {
        $mygate = [$v4gateway]
      } elsif $v6gateway != '' {
        $mygate = [$v6gateway]
      }

      if $v4gateway != '' or $v6gateway != '' {
        file { '/etc/mygate':
          owner   => 'root',
          group   => '0',
          mode    => '0644',
          content => inline_template("<%= @mygate.join(\"\n\") + \"\n\" %>"),
        }
      }
    }
    'freebsd': {
      Shell_config { file => '/etc/rc.conf' }

      # Should we enable IPv4 forwarding?
      if $v4forwarding {
        shell_config { 'gateway_enable':
          key   => 'gateway_enable',
          value => 'YES',
        }
      } else {
        shell_config { 'gateway_enable':
          ensure => absent,
          key    => 'gateway_enable',
          value  => 'YES',
        }
      }

      # Should we enable IPv6 forwarding?
      if $v6forwarding {
        shell_config { 'ipv6_gateway_enable':
          key   => 'ipv6_gateway_enable',
          value => 'YES',
        }
      } else {
        shell_config { 'ipv6_gateway_enable':
          ensure => absent,
          key    => 'ipv6_gateway_enable',
          value  => 'YES',
        }
      }

      # What is our IPv4 default router?
      if $v4gateway != '' {
        shell_config { 'defaultrouter':
          key   => 'defaultrouter',
          value => $v4gateway,
        }
      } else {
        shell_config { 'defaultrouter':
          ensure => absent,
          key    => 'defaultrouter',
          value  => $v4gateway,
        }
      }

      # What is our IPv6 default router?
      if $v6gateway != '' {
        shell_config { 'ipv6_defaultrouter':
          key   => 'ipv6_defaultrouter',
          value => $v6gateway,
        }
      } else {
        shell_config { 'ipv6_defaultrouter':
          ensure => absent,
          key    => 'ipv6_defaultrouter',
          value  => $v6gateway,
        }
      }
    }
  }
}
