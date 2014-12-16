# Class: bsd::network::carp
#
# Enable CARP in the kernel
#
class bsd::network::carp (
  $allowed = true,
  $preempt = false,
) {

  if $allowed == true {
    sysctl::value { 'net.inet.carp.allow': value => '1' }
  } else {
    sysctl::value { 'net.inet.carp.allow': value => '0' }
  }

  if $preempt == true {
    sysctl::value { 'net.inet.carp.preempt': value => '1' }
  } else {
    sysctl::value { 'net.inet.carp.preempt': value => '0' }
  }
}
