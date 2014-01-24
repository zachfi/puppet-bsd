# Define: bsd::network::interface::trunk
#
# Handles the creation and configuration of trunk(4) interfaces.
#
define bsd::network::interface::trunk (
  $interface,
  $proto       = 'lacp',
  $address     = undef,
  $description = undef,
) {

  $if_name = $name

  $config = {
    interface => $interface,
    proto     => $proto,
    address   => $address,
  }

  $trunk_ifconfig = get_hostname_if_trunk($config)

  bsd::network::interface { $if_name:
    description => $description,
    values      => [$trunk_ifconfig, 'up'],
  }
}
