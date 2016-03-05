require 'puppet_x/bsd/ifconfig'

Puppet::Type.type(:bsd_interface).provide(:ifconfig) do
  desc "Manage a BSD network interface state"

  confine :kernel => [:openbsd, :freebsd]
  commands :ifconfig => '/sbin/ifconfig'
  mk_resource_methods

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.instances
    iflist = Array.new()
    begin
      destroyable_interfaces = self.destroyables()
      output = execute(['/sbin/ifconfig'], :failonfail => false, :combine => true)
      PuppetX::BSD::Ifconfig.new(output).parse.each {|k,v|
        if_properties = {
          :ensure => :present,
          :provider => :bsd_interface,
          :name => k.to_s,
          :flags => v[:flags],
          :mtu => v[:mtu].to_i
        }

        if destroyable_interfaces.select {|i| k =~ /^#{i}/ }.size > 0
          if_properties[:destroyable] = :true
        else
          if_properties[:destroyable] = :false
        end

        if v[:flags]
          if v[:flags].include? 'UP'
            if_properties[:state] = :up
          else
            if_properties[:state] = :down
          end
        end

        iflist << new(if_properties)
      }
      return iflist
    rescue Puppet::ExecutionFailure
      nil
    end
  end

  def self.destroyables
      execute(['/sbin/ifconfig', '-C'], :failonfail => false, :combine => true).split(' ')
  end

  def up
    @property_hash[:ensure] = :up
  end

  def down
    @property_hash[:ensure] = :down
  end

  def create
    @property_hash[:ensure] = :present
    self.class.resource_type.validproperties.each do |property|
      if val = @resource.should(property)
        @property_hash[property] = val
      end
    end
  end

  def destroy
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] != :absent
  end

  def ifconfig(value)
    execute(['/sbin/ifconfig', @property_hash[:name], value], :failonfail => false, :combine => true)
  end

  def ifup
    ifconfig('up')
  end

  def ifdown
    ifconfig('down')
  end

  def ifdestroy
    ifconfig('destroy')
  end

  def ifcreate
    ifconfig('create')
  end

  def flush
    # Determine destroyability.  This is detected in self.instances if the
    # current resources already exists, but for new resources we need to make
    # the call to ifconfig to determine which resources are available for
    # creation/destruction.
    if @property_hash[:destroyable]
      if @property_hash[:destroyable] == :true
        destroyable = true
      else
        destroyable = false
      end
    else
      if self.class.destroyables.select {|i| @property_hash[:name] =~ /^#{i}/ }.size > 0
        destroyable = true
      else
        destroyable = false
      end
    end

    case @property_hash[:ensure]
    when :absent
      if @property_hash[:state] == :up
        ifdown
      end
      if destroyable
        ifdestroy
      end
    when :present
      if destroyable and @property_hash[:state] == :absent
        ifcreate
      end
    when :up
      if [:down, :absent].include? @property_hash[:state]
        if destroyable and @property_hash[:state] == :absent
          ifcreate
        end
        ifup
      end
    when :down
      if destroyable and @property_hash[:state] == :absent
        ifcreate
      end
      if @property_hash[:state] == :up
        ifdown
      end
    end

  end
end
