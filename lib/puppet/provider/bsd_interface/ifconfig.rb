Puppet::Type.type(:bsd_interface).provide(:ifconfig) do
  desc "Manage a BSD network interface state"

  confine :kernel => [:openbsd, :freebsd]
  defaultfor :operatingsystem => :freebsd

  commands :ifconfig => '/sbin/ifconfig'

  def pseudo_devices
    ifconfig(['-C']).split(' ')
  end

  def destroyable?
    pseudo_devices.each {|d|
      if resource[:name] =~ /#{d}/
        return true
      end
    }
    false
  end

  def up
    ifconfig([resource[:name], 'up'])
  end

  def down
    ifconfig([resource[:name], 'down'])
  end

  def create
    if destroyable?
      ifconfig([resource[:name], 'create'])
    end
    up()
  end

  def destroy
    down()
    if destroyable? and state != 'absent'
      ifconfig([resource[:name], 'destroy'])
    end
  end

  def exists?
    state() != 'absent'
  end
end
