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
define bsd::network::interface (
  $ensure        = 'present',
  $description   = undef,
  $values        = undef,
  $options       = undef,
) {

  $if_name        = $name
  $interface_file = "/etc/hostname.${if_name}"
  $if_type        = split($if_name, '\d+')

  validate_re(
    $ensure,
    '(up|down|present|absent)',
    '$ensure can only be one of up, down, present, or absent'
  )

  $config = {
    'name'        => $name,
    'type'        => $if_type[0],
    'description' => $description,
    'values'      => $values,
    'options'     => $options,
  }

  # Set a more common ensure value in a variable
  case $ensure {
    'present','up','down': {
      $file_ensure = 'present'
    }
    'absent': {
      $file_ensure = 'absent'
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
  }

  debug("config: ${config}")

  case $::kernel {
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
      }

      if $file_ensure == 'present' {
        exec { "netstart_${if_name}":
          command     => "/bin/sh /etc/netstart ${if_name}",
          refreshonly => true,
          subscribe   => File["/etc/hostname.${if_name}"],
        }
      }

      bsd_interface { $if_name:
        ensure => $ensure,
      }
    }
    'FreeBSD': {
      $rec_hash = get_freebsd_rc_conf_shellconfig($config)

      Shell_config {
        ensure => $file_ensure,
        file   => '/etc/rc.conf'
      }

      create_resources('shell_config', $rec_hash)

      if $state == 'up' {
        $action = 'start'
      } elsif $state == 'down' {
        $action = 'stop'
      }

      exec { "netifstart_${if_name}":
        command     => "/usr/sbin/service netif ${action} ${if_name}",
        refreshonly => true,
      }

      bsd_interface { $if_name:
        ensure => $ensure,
      }
    }
    default: {
      fail('unhandled BSD, please help add support')
    }
  }
}
