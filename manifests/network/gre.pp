class bsd::network::gre (
  $allowed = true
) {

  if $allowed == true {
    sysctl::value { 'net.inet.gre.allow': value => 1 }
  } else {
    sysctl::value { 'net.inet.gre.allow': value => 0 }
  }
}
