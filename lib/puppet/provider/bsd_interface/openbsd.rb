Puppet::Type.type(:bsd_interface).provide(:openbsd, :parent => :ifconfig) do
  confine :kernel => [:openbsd]
  defaultfor :kernel => [:openbsd]
  commands :sh => 'sh'

  def restart
    sh('/etc/netstart', resource[:name])
  end
end
