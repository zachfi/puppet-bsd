begin
  require 'ipaddress'
rescue => e
  puts e.message
  puts e.backtrace.inspect
end

require 'puppet/util/package'
require_relative '../../puppet_x/bsd/hostname_if/inet'
require_relative '../../puppet_x/bsd/puppet_interface'

class Hostname_if < PuppetX::BSD::PuppetInterface
  attr_reader :content

  include Puppet::Util::Package

  def initialize(config)
    options :desc,
      :type,
      :options,
      :addresses,
      :raw_values,
      :mtu

    multiopts :addresses, :options, :raw_values
    oneof :addresses, :raw_values, :options, :desc
    #exclusive :addresses, :raw_values

    configure(config)

    @desc = @config[:desc]
    @type = @config[:type]

    @addresses = [@config[:addresses]].flatten
    @items     = [@config[:raw_values]].flatten
    @options   = [@config[:options]].flatten

    @addresses.reject!{ |i| i == nil or i == :undef }
    @items.reject!{ |i| i == nil or i == :undef }
    @options.reject!{ |i| i == nil or i == :undef }
  end

  # Check to see if we have a description
  def has_description?
    @desc and @desc.is_a? String and @desc.length > 0
  end

  def has_addresses?
    @addresses and @addresses.is_a? Array and @addresses.size > 0
  end

  def has_options?
    @options and @options.is_a? Array and @options.size > 0
  end

  # Receives array of strings that match an inet or inet6 configuration
  # Address parsing is kept here for a while for backward compatibility
  #
  # Yields complete, formatted lines
  def process_items(items)
    if items

      # We begin here with no IPs set.  This is used to determin if we are
      # setting the primary address, or simply providing an alias to an
      # already existing interface.
      ipset  = false
      ip6set = false

      # Process each one of the line items
      items.each {|i|
        # Return the dynamic address assignemnt if found
        if i =~ /^(dhcp)$/
          yield i
        elsif i =~ /^(rtsol|inet6 autoconf)$/
          yield i
        # yield up/down if found
        elsif i  =~ /^(up|down)$/
          yield i
        # Yield the command string in full
        elsif i =~ /^!/
          yield i
        else
          begin
            ip = IPAddress i
            if ip.ipv6?
              line = ['inet6']
              line << 'alias' if ip6set
              line << ip.compressed
              line << ip.prefix
              ip6set = true
            elsif ip.ipv4?
              line = ['inet']
              line << 'alias' if ipset
              line << ip.address
              line << ip.netmask
              line << 'NONE'
              ipset = true
            end
            if line
              yield line.join(' ')
            else
              puts line
              puts "line not found"
            end
          rescue ArgumentError
            # In the case we have received something we don't know how to
            # handle, and is not an IP address as caught here in the else, then
            # we just send it back unmodified.
            yield i
          end
        end
      }
    else
      nil
    end
  end

  # Return an array, each element containing a line of text to match the
  # hostname_if(5) configuration style.
  def lines
    lines = []

    supported_wifi_devices = [
      'ath',
      'athn',
      'iwn',
      'ral',
      'rum',
      'wi',
      'wpi',
    ]

    supported_virtual_devices = [
      'bridge',
      'carp',
      'enc',
      'gif',
      'gre',
      'pflog',
      'pflow',
      'pfsync',
      'trunk',
      'tun',
      #'vether',
      'vlan',
    ]

    # please_help_add_support_for = [
    #   'mpe',
    #   'mpw',
    #   'ppp',
    #   'pppoe',
    #   'sl',
    #   'svlan',
    #   'vxlan',
    # ]

    if has_addresses?
      PuppetX::BSD::Hostname_if::Inet.new(@addresses).process {|i|
        lines << i
      }
    end

    # Supported interfaces return the already processed lines.
    if supported_virtual_devices.include?(@iftype)
      lines.push(*@items)
    elsif supported_wifi_devices.include?(@iftype)
      lines.push(*@items)
    else
      Puppet.info @iftype

      process_items(@addresses) {|line|
        lines.push(*line)
      }

      # The process_items method is only used for items to ensure that
      # options who need to be on their own line are yieled as such.  A
      # failure to process a line as a a known option or an IP address will
      # result in the complete item being sent back.
      process_items(@items) {|line|
        lines.push(*line)
      }
    end

    if has_options?
      options_string = @options.join(' ')
    end

    if has_description?
      description_string = "description \"#{@desc}\""
    end

    # Set the interface options
    #
    # If we have received interface options, append it to the content of
    # the first line.
    if has_options?
      tmp = lines.shift
      lines.unshift([tmp, options_string].join(' '))
    end

    # Include the description string
    #
    # If we have received a description string, include it as the first
    # line in the absense of interface options.  In the presense of
    # interface options, we append the description to the end of the first
    # line.
    if has_description?
      if has_options?
        tmp = lines.shift
        lines.unshift([tmp, description_string].join(' '))
      else
        lines.unshift(description_string)
      end
    end

    lines
  end

  # Format the lines[] array as content for a file.
  def content
    lines().join("\n")
  end
end
