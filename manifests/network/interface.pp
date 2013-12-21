# Define: bsd::network::interface
#
# Manage a network interface
#
define bsd::network::interface (
  $ensure        = 'present',
  $description   = undef,
  $values        = undef,
  $options       = undef,
  #$commands      = undef,
) {

  $if_name = $name
  $interface_file = "/etc/hostname.${if_name}"

  $config = {
    description    => $description,
    values         => $values,
    options        => $options,
  }

  $content = get_openbsd_hostname_if_content($config)
  notice($content)

  file { "/etc/hostname.${if_name}":
    content => $content,
    notify  => Exec["netstart_${if_name}"],
  }

  exec { "netstart_${if_name}":
    command     => "/bin/sh /etc/netstart ${if_name}",
    refreshonly => true,
  }
}
