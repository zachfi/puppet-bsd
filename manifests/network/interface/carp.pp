# Define: bsd::network::interface::carp
#
# Handles the creation and configuration of carp(4) interfaces.
#
define bsd::network::interface::carp (
  $id,
  $address,
  $device,
  $advbase     = undef,
  $advskew     = undef,
  $description = undef,
  $pass        = undef,
) {

  include bsd::network::carp

  $if_name = $name

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
    description => $description,
    values      => [$carp_ifconfig, 'up'],
  }
}
