define bsd::network::route (
  $value,
  Enum['present', 'absent'] $ensure = 'present',
) {
  case $facts['kernel'] {
    'FreeBSD': {
      case $ensure {
        'present': {
          $static_route_ensure = 'present'
        }
        'absent': {
          $static_route_ensure = 'absent'
        }
        default: {
          fail('Incorrect state ensure set for shellvar')
        }
      }

      shellvar { "static_routes_${name}":
        ensure       => $static_route_ensure,
        variable     => 'static_routes',
        target       => '/etc/rc.conf',
        value        => $name,
        array_append => true,
      }

      shellvar { "route_${name}":
        ensure   => $static_route_ensure,
        variable => "route_${name}",
        target   => '/etc/rc.conf',
        value    => $value,
      }
    }
    default: {
      notify { 'Route management not supported in this class': }
    }
  }
}
