Puppet::Type.type(:bsd_interface).provide(:ifconfig) do
  desc "Manage a BSD network interface state"

  confine :kernel => [:openbsd, :freebsd]
  commands :ifconfig => '/sbin/ifconfig'
  #mk_resource_methods

  def get_state
    output = execute(['/sbin/ifconfig', resource[:name]], :failonfail => false, :combine => true)
    return output
  end

  def state
    @state_output ||= get_state()

    case @state_output
    when /#{resource[:name]}:\sflags=.*<[^UP].*>/
      return 'down'
    when /#{resource[:name]}:\sflags=.*<UP,/
      return 'up'
    else
      return 'absent'
    end
  end

  def state=(value)
    case value
    when 'up'
      up()
    when 'down'
      down()
    end
  end

  def pseudo_devices
    @pseudo_devices ||= ifconfig(['-C']).split(' ')
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
    if destroyable? and state() == 'absent'
      ifconfig([resource[:name], 'create'])
      up()
    elsif state() != 'up'
      up()
    end
  end

  def destroy
    down()
    if destroyable? and state() != 'absent'
      ifconfig([resource[:name], 'destroy'])
    end
  end

  def exists?
    if destroyable?
      state() != 'absent'
    else
      state() != 'absent' and state() != 'down'
    end
  end
end
