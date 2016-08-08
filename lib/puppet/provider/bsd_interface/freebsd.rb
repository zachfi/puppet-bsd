Puppet::Type.type(:bsd_interface).provide(:freebsd, :parent => :ifconfig) do
  confine :kernel => [:freebsd]
  defaultfor :kernel => [:freebsd]

  def restart
    execute(['/usr/sbin/service', 'netif', 'restart', resource[:name]], :failonfail => false)
  end

  def flush
    super
    restart
  end
end
