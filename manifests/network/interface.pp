# Define: bsd::network::interface
#
# Manage a network interface
#
# This define is a generic interface to the underlying bsd interface
# configuration.  For OpenBSD, manage the hostname_if(5) config files, and
# rc.conf(5) on FreeBSD.
#
# This code can be implemented and used directly, though there are specific
# Puppet classes for many common network interface configuration, such as vlan,
# carp, trunk, and it is recommended to use the more specific classes when
# available.
#
# @param state One of up, down, present or absent
# @param description A short description of the interface
# @param addresses An array of IPv4 or IPv6, or the keywords
# @param raw_values An array values to pass directly to the interface configuration
# @param options An array of option values to set
# @param parents An array of interface names to which this interface belongs
# @param mtu An integer representing the Maxium Transmition unit
#
define bsd::network::interface (
  Pattern[/^(up|down|present|absent)$/] $ensure = 'present',
  Optional[String] $description                 = undef,
  Optional[Array] $addresses                    = undef,
  Optional[Array] $raw_values                   = undef,
  Optional[Array] $options                      = undef,
  Optional[Array] $parents                      = undef,
  Optional[Integer] $mtu                        = undef,
) {
  $if_name        = $name
  $if_type        = split($if_name, '\d+')

  $config = {
    'name'        => $name,
    'type'        => $if_type[0],
    'description' => $description,
    'addresses'   => $addresses,
    'raw_values'  => $raw_values,
    'options'     => $options,
    'mtu'         => $mtu,
  }

  # Set a more common ensure value in a variable
  case $ensure {
    'present','up','down': {
      $file_ensure = 'present'
    }
    'absent': {
      $file_ensure = 'absent'
    }
    default: {
      fail('Incorrect file "ensure" set')
    }
  }

  # Set the interface state variable
  case $ensure {
    'present','up': {
      $state = 'up'
    }
    'absent','down': {
      $state = 'down'
    }
    default: {
      fail('Incorrect state variable set')
    }
  }

  case $facts['kernel'] {
    'OpenBSD': {
      if $file_ensure == 'present' {
        $content = get_openbsd_hostname_if_content($config)

        if $state != undef {
          $text = inline_template('<%= [@content,@state].join("\n") + "\n" %>')
        } else {
          $text = inline_template('<%= @content + "\n" %>')
        }
      } else {
        $text = ''
      }

      file { "/etc/hostname.${if_name}":
        ensure  => $file_ensure,
        content => $text,
        notify  => Bsd_interface[$if_name],
      }

      bsd_interface { $if_name:
        ensure  => $state,
        parents => $parents,
        mtu     => $mtu,
        require => File["/etc/hostname.${if_name}"],
      }
    }
    'FreeBSD': {
      $rec_hash = get_freebsd_rc_conf_shellvar($config)

      $shellvar_defaults = {
        ensure => $file_ensure,
        target => '/etc/rc.conf',
        before => Bsd_interface[$if_name],
        notify => Bsd_interface[$if_name],
      }

      create_resources('shellvar', $rec_hash, $shellvar_defaults)

      if $state == 'up' {
        $action = 'start'
      } elsif $state == 'down' {
        $action = 'stop'
      }

      bsd_interface { $if_name:
        ensure  => $state,
        parents => $parents,
        mtu     => $mtu,
      }

      bsd::network::interface::cloned { $if_name:
        ensure => $ensure,
      }
    }
    default: {
      fail('unhandled BSD, please help add support!')
    }
  }
}
