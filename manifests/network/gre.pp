# Class: bsd:::network::gre
#
# Enable or disable GRE, WCCP
# And MobileIP
#
class bsd::network::gre (
  $allowed  = true,
  $wccp     = false,
  $mobileip = false,
) {

  if $allowed == true {
    sysctl { 'net.inet.gre.allow':
      ensure => present,
      value  => '1',
    }
  } else {
    sysctl { 'net.inet.gre.allow':
      ensure => present,
      value  => '0',
    }
  }

  if $wccp == true {
    sysctl { 'net.inet.gre.wccp':
      ensure => present,
      value  => '1',
    }
  } else {
    sysctl { 'net.inet.gre.wccp':
      ensure => present,
      value  => '0',
    }
  }

  if $mobileip == true {
    sysctl { 'net.inet.mobileip.allow':
      ensure => present,
      value  => '1',
    }
  } else {
    sysctl { 'net.inet.mobileip.allow':
      ensure => present,
      value  => '0',
    }
  }
}
