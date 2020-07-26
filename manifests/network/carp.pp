# Class: bsd::network::carp
#
# Enable CARP in the kernel
#
class bsd::network::carp (
  $allowed = true,
  $preempt = false,
) {
  if $allowed == true {
    sysctl { 'net.inet.carp.allow':
      ensure => present,
      value  => '1',
    }
  } else {
    sysctl { 'net.inet.carp.allow':
      ensure => present,
      value  => '0',
    }
  }

  if $preempt == true {
    sysctl { 'net.inet.carp.preempt':
      ensure => present,
      value  => '1',
    }
  } else {
    sysctl { 'net.inet.carp.preempt':
      ensure => present,
      value  => '0',
    }
  }
}
