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
  validate_re($if_name, ['trunk'])

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

  case $::kernel {
    'FreeBSD': {
      fail('trunk interfaces not implemented on FreeBSD')
    }
    'OpenBSD': {
      $trunk_ifconfig = get_hostname_if_trunk($config)
    }
    default: {
      fail('unhandled BSD, please help add support')
    }
  }

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
