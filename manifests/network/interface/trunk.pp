# Define: bsd::network::interface::trunk
#
# Handles the creation and configuration of trunk(4) interfaces.
#
define bsd::network::interface::trunk (
  $interface,
  $ensure      = 'present',
  $proto       = 'lacp',
  $address     = undef,
  $description = undef,
  $values      = undef,
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
  }

  if $values {
    $trunk_values = concat([$trunk_ifconfig], $values)
  } else {
    $trunk_values = [$trunk_ifconfig]
  }

  bsd::network::interface { $if_name:
    ensure      => $ensure,
    description => $description,
    values      => $trunk_values,
    parents     => [$interface],
  }
}
