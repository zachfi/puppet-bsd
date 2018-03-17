begin
  require 'ipaddress'
rescue => e
  puts e.message
  puts e.backtrace.inspect
end

require_relative '../../puppet_x/bsd'
require_relative '../../puppet_x/bsd/puppet_interface'

class Rc_conf < PuppetX::BSD::PuppetInterface
  def initialize(config)
    validation :name
    options :desc, :addresses, :options, :raw_values, :mtu
    integers :mtu
    multiopts :addresses, :options, :raw_values
    oneof :name, :desc

    configure(config)

    # Ugly junk
    @name       = @config[:name]
    @desc       = @config[:desc]
    @addresses  = [@config[:addresses]].flatten
    @raw_values = @config[:raw_values]
    @options    = [@config[:options]].flatten
    @addresses.reject! { |i| i.nil? || (i == :undef) }
    @options.reject! { |i| i.nil? || (i == :undef) }
    Puppet.debug("Config is: #{@config}")

    # The blob
    @data = load_hash
  end

  def options_string
    result = ''

    result = @options.join(' ') if @options && !@options.empty?
    result = result.to_s + " mtu #{@config[:mtu]}" if @config.keys.include? :mtu
    result
  end

  def get_hash
    @data
  end

  # Return a hash formatted for the create_resources() function
  # in puppet see shellvar resource
  def to_create_resources
    resources = {}
    Puppet.debug("Data is: #{@data}")

    @data.each_key do |topkey|
      # The top level key is the interface name
      ifname = topkey.to_sym

      if @data[topkey][:addrs]
        if @data[topkey][:addrs].is_a? Array
          @data[topkey][:addrs].each do |i|
            key = if i =~ %r{inet6 }
                    "ifconfig_#{ifname}_ipv6"
                  elsif i =~ %r{inet }
                    "ifconfig_#{ifname}"
                  else
                    "ifconfig_#{ifname}"
                  end

            # Set the value property on the resource
            resources[key] = {
              'value' => i
            }
          end
        else
          key = "ifconfig_#{ifname}"
          resources[key] = {
            'value' => @data[topkey][:addrs]
          }
        end

      elsif @raw_values
        key = "ifconfig_#{ifname}"
        resources[key] = {
          'value' => @raw_values.join(' '),
        }
      end

      next unless @data[topkey][:aliases] && @data[topkey][:aliases].is_a?(Array)
      @data[topkey][:aliases].each_with_index do |a, i|
        key = "ifconfig_#{ifname}_alias#{i}"
        resources[key] = {
          'value' => a
        }
      end
    end

    Puppet.debug("Returning resources: #{resources}")

    resources
  end

  private

  # Load the ifconfig hash that will contain all addresses (v4 and v6), including
  # alias addresses.
  def load_hash
    ifconfig = {}
    aliases  = []
    addrs    = []

    # Initially, the IP and IP6 has not been set.  This helps track whether
    # we are creating aliases or the first of the addresses.
    ip6set   = false
    ipset    = false

    process_addresses(@addresses) do |addr|
      if addr =~ %r{DHCP}
        addrs << addr
      elsif addr =~ %r{inet6 }
        if ip6set
          aliases << addr
        else
          addrs << addr
          ip6set = true
        end
      elsif addr =~ %r{inet }
        if ipset
          aliases << addr
        else
          addrs << addr
          ipset = true
        end
      else
        raise ArgumentError('unhandled address family')
      end
    end

    # append the options to the first address
    opts = options_string

    if !addrs.empty?
      ifconfig[:addrs] = addrs

      if opts && !opts.empty?
        ifconfig[:addrs][0] = [ifconfig[:addrs][0], opts].join(' ')
      end
    else
      ifconfig[:addrs] = options_string if opts && !opts.empty?
    end

    ifconfig[:aliases] = aliases unless aliases.empty?

    { @name.to_sym => ifconfig }
  end

  def process_addresses(addresses)
    addresses.each do |a|
      if a =~ %r{^(DHCP|dhcp)}
        yield 'DHCP'
      else
        begin
          ip = IPAddress a
          if ip.ipv6?
            value = ['inet6']
            value << ip.to_string
          elsif ip.ipv4?
            value = ['inet']
            value << ip.to_string
          end
          if value
            yield value.join(' ')
          else
            raise 'Value not found'
          end
        rescue Exception => e
          raise "addr is #{a} of class #{a.class}: #{e.message}"
        end
      end
    end
  end
end
