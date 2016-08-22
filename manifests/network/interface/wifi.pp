# Define: bsd::network::interface::wifi
#
# Handles the creation and configuration of wifi interfaces.
#
define bsd::network::interface::wifi (
  $network_name,
  $ensure                  = 'present',
  $wpa_key                 = undef,
  Optional[Array] $address = undef,
  $description             = undef,
  $options                 = undef,
  $raw_values              = undef,
) {

  $if_name = $name

  validate_re(
    $ensure,
    '(up|down|present|absent)',
    '$ensure can only be one of up, down, present, or absent'
  )

  $config = {
    network_name => $network_name,
    wpa_key      => $wpa_key,
    address      => $address,
  }

  $wifi_ifconfig = get_hostname_if_wifi($config)

  if $raw_values {
    $wifi_values = concat([$wifi_ifconfig], $raw_values)
  } else {
    $wifi_values = [$wifi_ifconfig]
  }

  bsd::network::interface { $if_name:
    description => $description,
    raw_values  => $wifi_values,
    options     => $options,
  }
}
