require 'puppet/util/package'
require 'puppet_x/bsd/hostname_if/inet'
begin
  require 'ipaddress'
rescue => e
  puts e.message
  puts e.backtrace.inspect
end

module PuppetX
  module BSD
    class Hostname_if
      attr_reader :content

      include Puppet::Util::Package

      def initialize(config)
        @config = config
        validate_config()
        normalize_config()
      end

      def normalize_config

        @addresses = [@config[:addresses]].flatten
        @items     = [@config[:values]].flatten
        @options   = [@config[:options]].flatten

        @addresses.reject!{ |i| i == nil or i == :undef }
        @items.reject!{ |i| i == nil or i == :undef }
        @options.reject!{ |i| i == nil or i == :undef }
      end

      def validate_config

        # compensate for puppet oddities
        @config.reject!{ |k,v| k == :undef or v == :undef }

        config_items = [
          :type,
          :desc,
          :addresses,
          :values,
          :options,
        ]

        @config.each do |k,v|

          unless config_items.include? k
            raise ArgumentError, "unknown configuration item found: #{k}"
          end
        end

        if @config[:type]
          if @config[:type].is_a? String
            @iftype  = @config[:type].split(/\d+/).first
          else
            raise ArgumentError,
              "interface type must be a String, is: #{@config[:type].class}"
          end
        end

        if @config[:desc] or @config[:addresses] or @config[:values] or @config[:options]
          if @config[:desc]
            if @config[:desc].is_a? String
              @desc = @config[:desc]
            else
              raise ArgumentError,
                "description must be a String, is: #{@config[:desc].class}"
            end
          end

          if @config[:addresses]
            if [String, Array].include? @config[:addresses].class
              @values = @config[:addresses]
            else
              raise ArgumentError,
                "addresses must be a String or Array, is: #{@config[:addresses].class}"
            end
          end

          if @config[:values]
            if [String, Array].include? @config[:values].class
              @values = @config[:values]
            else
              raise ArgumentError,
                "values must be a String or Array, is: #{@config[:values].class}"
            end
          end

          if @config[:options]
            if [String, Array].include? @config[:options].class
              @options = @config[:options]
            else
              raise ArgumentError,
                "options can only be a String or an Array, is: #{@config[:options].class}"
            end
          end

        else
          raise ArgumentError,
            "a description, address, value, or option is required"
        end
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
              if has_addresses?
                raise ArgumentError, "Using the 'addresses' parameter in combination with setting IP information via 'values' parameter is not allowed"
              else
                Puppet.notice "Using the 'values' parameter is deprecated in favor of the 'addresses' in order to set #{i}"
              end
              yield i
            elsif i =~ /^(rtsol|inet6 autoconf)$/
              kernelversion = Facter.value('kernelversion')
              if has_addresses?
                raise ArgumentError, "Using the 'addresses' parameter in combination with setting IP information via 'values' parameter is not allowed"
              else
                Puppet.notice "Using the 'values' parameter is deprecated in favor of the 'addresses' in order to set #{i}"
              end
              if versioncmp(kernelversion, "5.6") <= 0
                yield 'rtsol'
              else
                yield 'inet6 autoconf'
              end
            # return up/down if found
            elsif i  =~ /^(up|down)$/
              yield i
            # Yield the command string in full
            elsif i =~ /^!/
              yield i
            else
              begin
                if has_addresses?
                  raise ArgumentError, "Using the 'addresses' parameter in combination with setting IP information via 'values' parameter is not allowed"
                else
                  Puppet.notice "Using the 'values' parameter is deprecated in favor of the 'addresses' in order to set #{i}"
                end
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
              rescue => e
                raise "addr is #{i} of class #{i.class}: #{e.message}"
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

          # Process other values given
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
  end
end
