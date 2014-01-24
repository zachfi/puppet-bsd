# Define: bsd::network::interface::vlan
#
# Handle the creation and configuration of vlan(4) interfaces.
#
define bsd::network::interface::vlan (
  $id,
  $device,
  $address,
  $description = undef,
) {

  $if_name = $name

  $config = {
    id      => $id,
    device  => $device,
    address => $address,
  }

  $vlan_ifconfig = get_hostname_if_vlan($config)

  bsd::network::interface { $if_name:
    description => $description,
    values      => [$vlan_ifconfig, 'up'],
  }
}
