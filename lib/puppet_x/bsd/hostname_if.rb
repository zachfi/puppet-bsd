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

      def initialize(config)
        @config = config
        validate_config()
        normalize_config()
      end

      def normalize_config

        @items   = [@config[:values]].flatten
        @options = [@config[:options]].flatten

        @items.reject!{ |i| i == nil or i == :undef }
        @options.reject!{ |i| i == nil or i == :undef }
      end

      def validate_config

        # compensate for puppet oddities
        @config.reject!{ |k,v| k == :undef or v == :undef }

        config_items = [
          :type,
          :desc,
          :values,
          :options
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

        if @config[:desc] or @config[:values] or @config[:options]
          if @config[:desc]
            if @config[:desc].is_a? String
              @desc = @config[:desc]
            else
              raise ArgumentError,
                "description must be a String, is: #{@config[:desc].class}"
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
          raise ArgumentError "a description, value, or option is required"
        end
      end

      # Check to see if we have a description
      def has_desc?
        @desc and @desc.is_a? String and @desc.length > 0
      end

      def description_string
        if has_desc?
          "description \"#{@desc}\""
        else
          ""
        end
      end

      # Append the description string to the options
      def build_options
          @options << description_string() if has_desc?
      end

      def options_string
        build_options
        @options.join(' ')
      end

      # Receivs array of strings that match an inet or inet6 configuration
      #
      # Yields complete, formatted lines
      def process_items(items)
        if items

          # We begin here with no IPs set.  This is used to determin if we are
          # setting the primary address, or simply providing an aliase to an
          # already existing interface.
          ipset  = false
          ip6set = false

          # Process each one of the line items
          items.each {|i|
            # Return the dynamic address assignemnt if found
            if i =~ /^(rtsol|dhcp)$/
              yield i
            # return up/down if found
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

        # Supported interfaces return the already processed lines.
        if @iftype =~ /^bridge/
        elsif @iftype =~ /^carp/
          lines = @items
        elsif @iftype =~ /^enc/
          lines = @items
        elsif @iftype =~ /^gif/
          lines = @items
        elsif @iftype =~ /^gre/
          lines = @items
        elsif @iftype =~ /^lo/
        elsif @iftype =~ /^mpe/
        elsif @iftype =~ /^pflog/
        elsif @iftype =~ /^pflow/
          lines = @items
        elsif @iftype =~ /^pfsync/
          lines = @items
        elsif @iftype =~ /^ppp/
        elsif @iftype =~ /^pppoe/
        elsif @iftype =~ /^sl/
        elsif @iftype =~ /^trunk/
          lines = @items
        elsif @iftype =~ /^tun/
          lines = @items
        elsif @iftype =~ /^vether/
        elsif @iftype =~ /^vlan/
          lines = @items
        elsif supported_wifi_devices.include?(@iftype)
          lines = @items
        else
          Puppet.info @iftype

          # Process the physical interface config
          process_items(@items) {|line|
            lines << line
          }
        end

        # Appends the media options to the first line, regardless of the type
        # of interface we are working with.
        if lines.length > 0
          lines[0] = ( lines[0].split() + options_string().split ).join(' ')
        else
          lines << options_string()
        end

        lines
      end

      # Return a string of content
      def content
        lines().join("\n")
      end
    end
  end
end
