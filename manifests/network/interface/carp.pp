# Define: bsd::network::interface::carp
#
# Handles the creation and configuration of carp(4) interfaces.
#
define bsd::network::interface::carp (
  $id,
  $address,
  $device,
  $ensure      = 'present',
  $advbase     = undef,
  $advskew     = undef,
  $description = undef,
  $pass        = undef,
) {

  include bsd::network::carp

  $if_name = $name
  validate_re($if_name, ['carp'])

  validate_re(
    $ensure,
    '(up|down|present|absent)',
    '$ensure can only be one of up, down, present, or absent'
  )

  $config = {
    address => $address,
    id      => $id,
    device  => $device,
    advbase => $advbase,
    advskew => $advskew,
    pass    => $pass,
  }

  $carp_ifconfig = get_hostname_if_carp($config)

  bsd::network::interface { $if_name:
    ensure      => $ensure,
    description => $description,
    values      => [$carp_ifconfig],
  }
}
