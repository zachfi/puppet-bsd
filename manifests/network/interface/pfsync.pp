# Define: bsd::network::interface::pfsync
#
# Handles the creation and configuration of pfsync(4) interfaces.
#
define bsd::network::interface::pfsync (
  $ensure      = 'present',
  $syncdev     = undef,
  $syncpeer    = undef,
  $maxupd      = undef,
  $defer       = undef,
  $description = undef,
  $values      = undef,
) {

  $if_name = $name
  validate_re($if_name, ['pfsync'])

  validate_re(
    $ensure,
    '(up|down|present|absent)',
    '$ensure can only be one of up, down, present, or absent'
  )

  $config = {
    syncdev  => $syncdev,
    syncpeer => $syncpeer,
    maxupd   => $maxupd,
    defer    => $defer,
  }

  case $::kernel {
    'FreeBSD': {
      fail('pfsync interfaces not implemented on FreeBSD')
    }
    'OpenBSD': {
      $pfsync_ifconfig = get_hostname_if_pfsync($config)
    }
    default: {
      fail('unhandled BSD, please help add support')
    }
  }

  if $values {
    $pfsync_values = concat([$pfsync_ifconfig], $values)
  } else {
    $pfsync_values = [$pfsync_ifconfig]
  }

  bsd::network::interface { $if_name:
    ensure      => $ensure,
    description => $description,
    values      => $pfsync_values,
    parents     => flatten([$syncdev]),
  }
}
