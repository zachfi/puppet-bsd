# Class: bsd::network::carp
#
# Enable CARP in the kernel
#
class bsd::network::carp (
  $allowed = true,
  $preempt = false,
  $kernmod = false,
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

  # if kernmod is true, add carp_load="YES" to /boot/loader.conf
  # and run kldload carp
  if $kernmod == true {
    case $::osfamily {
      'FreeBSD': {
        file_line { 'carp_load_line':
          path => '/boot/loader.conf',
          line => 'carp_load="YES"',
        }

        exec { 'load_carp':
          command => '/sbin/kldload carp',
          unless  => '/sbin/kldstat -n carp.ko',
        }
      }
      default: {
        fail("${::osfamily} does not need to load this kernel module")
      }
    }
  }
}
