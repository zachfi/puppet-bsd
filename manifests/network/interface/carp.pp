define bsd::network::interface::carp (
  $vhid,
  $address,
  $advbase     = undef,
  $advskew     = undef,
  $carpdev     = undef,
  $description = undef,
  $pass        = undef,
) {

  include bsd::network::carp

  $if_name = $name

  $config = {
    address => $address,
    vhid    => $vhid,
    advbase => $advbase,
    advskew => $advskew,
    carpdev => $carpdev,
  }

  $carp_ifconfig = get_carp_ifconfig($config)

  bsd::network::interface { $if_name:
    description => $description,
    values      => [$carp_ifconfig, 'up'],
  }
}
