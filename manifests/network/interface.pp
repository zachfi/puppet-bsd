# Define: bsd::network::interface
#
# Manage a network interface
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

  $config = {
    type        => $if_type[0],
    description => $description,
    values      => $values,
    options     => $options,
  }

  debug("config: ${config}")

  $content = get_openbsd_hostname_if_content($config)

  debug("content: ${content}")

  file { "/etc/hostname.${if_name}":
    content => inline_template('<%= content + "\n" %>'),
    notify  => Exec["netstart_${if_name}"],
  }

  exec { "netstart_${if_name}":
    command     => "/bin/sh /etc/netstart ${if_name}",
    refreshonly => true,
  }
}
