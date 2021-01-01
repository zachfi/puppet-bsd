# Define: bsd::network::interface::trunk
#
# Handles the creation and configuration of trunk(4) interfaces.
#
define bsd::network::interface::trunk (
  $interface,
  $ensure                  = 'present',
  $proto                   = 'lacp',
  Optional[Array] $address = undef,
  $description             = undef,
  $raw_values              = undef,
) {
  $if_name = $name
  case $facts['kernel'] {
    'FreeBSD': {
      validate_re($if_name, ['lagg'])
    }
    'OpenBSD': {
      validate_re($if_name, ['trunk'])
    }
    default: {}
  }

  validate_re(
    $ensure,
    '(up|down|present|absent)',
    '$ensure can only be one of up, down, present, or absent'
  )

  $config = {
    interface => $interface,
    proto     => $proto,
    address   => $address,
  }

  case $facts['kernel'] {
    'FreeBSD': {
      $trunk_options = get_rc_conf_trunk($config)

      bsd::network::interface { $if_name:
        ensure      => $ensure,
        description => $description,
        addresses   => $address,
        options     => $trunk_options,
        parents     => flatten([$interface]),
      }
    }
    'OpenBSD': {
      $trunk_ifconfig = get_hostname_if_trunk($config)

      if $raw_values {
        $trunk_values = concat([$trunk_ifconfig], $raw_values)
      } else {
        $trunk_values = [$trunk_ifconfig]
      }

      bsd::network::interface { $if_name:
        ensure      => $ensure,
        description => $description,
        raw_values  => $trunk_values,
        parents     => flatten([$interface]),
      }
    }
    default: {
      fail('unhandled BSD, please help add support')
    }
  }
}
