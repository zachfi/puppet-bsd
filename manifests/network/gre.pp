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
    sysctl::value { 'net.inet.gre.allow': value => '1' }
  } else {
    sysctl::value { 'net.inet.gre.allow': value => '0' }
  }

  if $wccp == true {
    sysctl::value { 'net.inet.gre.wccp': value => '1' }
  } else {
    sysctl::value { 'net.inet.gre.wccp': value => '0' }
  }

  if $mobileip == true {
    sysctl::value { 'net.inet.mobileip.allow': value => '1' }
  } else {
    sysctl::value { 'net.inet.mobileip.allow': value => '0' }
  }
}
