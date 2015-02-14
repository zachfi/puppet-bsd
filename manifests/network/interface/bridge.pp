# Define: bsd::network::interface::bridge
#
# Handle the creation and configuration of bridge(4) interfaces.
#
define bsd::network::interface::bridge (
  $interface,
  $description = undef,
) {

  $if_name = $name
  validate_re($if_name, ['bridge'])

  $config = {
    interface => $interface,
  }

  $bridge_ifconfig = get_hostname_if_bridge($config)

  bsd::network::interface { $if_name:
    description => $description,
    values      => [$bridge_ifconfig, 'up'],
  }
}
