require_relative '../../../puppet_x/bsd/ifconfig'

Puppet::Type.type(:bsd_interface).provide(:ifconfig) do
  desc 'Manage a BSD network interface state'

  confine kernel: [:openbsd, :freebsd]
  commands ifconfig: '/sbin/ifconfig'
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def self.instances
    iflist = []
    begin
      destroyable_interfaces = destroyables
      output = execute(['/sbin/ifconfig'], failonfail: false, combine: true)
      PuppetX::BSD::Ifconfig.new(output).parse.each do |k, v|
        if_properties = {
          ensure: :present,
          provider: :bsd_interface,
          name: k.to_s,
          flags: v[:flags],
          mtu: v[:mtu].to_i,
          groups: v[:groups].split()
        }

        if_properties[:destroyable] = if !destroyable_interfaces.select { |i| k =~ %r{^#{i}} }.empty?
                                        :true
                                      else
                                        :false
                                      end

        if v[:flags]
          if_properties[:state] = if v[:flags].include? 'UP'
                                    :up
                                  else
                                    :down
                                  end
        end

        iflist << new(if_properties)
      end
      return iflist
    rescue Puppet::ExecutionFailure
      nil
    end
  end

  def self.destroyables
    execute(['/sbin/ifconfig', '-C'], failonfail: false, combine: true).split(' ')
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
    execute(['/sbin/ifconfig', @property_hash[:name], value], failonfail: false, combine: true)
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

  def mtu=(value)
    @property_flush[:mtu] = value
  end

  def flush
    # Determine destroyability.  This is detected in self.instances if the
    # current resources already exists, but for new resources we need to make
    # the call to ifconfig to determine which resources are available for
    # creation/destruction.
    destroyable = if @property_hash[:destroyable]
                    if @property_hash[:destroyable] == :true
                      true
                    else
                      false
                    end
                  elsif !self.class.destroyables.select { |i| @property_hash[:name] =~ %r{^#{i}} }.empty?
                    true
                  else
                    false
                  end

    case @property_hash[:ensure]
    when :absent
      ifdown if @property_hash[:state] == :up
      ifdestroy if destroyable
    when :present
      ifcreate if destroyable && (@property_hash[:state] == :absent)
    when :up
      if [:down, :absent].include? @property_hash[:state]
        ifcreate if destroyable && (@property_hash[:state] == :absent)
        ifup
      end
    when :down
      ifcreate if destroyable && (@property_hash[:state] == :absent)
      ifdown if @property_hash[:state] == :up
    end

    if [:up, :present].include? @property_hash[:ensure]
      ifconfig("mtu #{@property_flush[:mtu]}") if @property_flush[:mtu]
    end
  end
end
