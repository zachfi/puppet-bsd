begin
  require 'ipaddress'
rescue => e
  puts e.message
  puts e.backtrace.inspect
end

module PuppetX
  module BSD
    class Rc_conf

      def initialize(config)
        @config = config
        validate_config()
        normalize_config()
        @data = load_hash
      end

      def normalize_config
        @name    = @config[:name]
        @desc    = @config[:desc]
        @address = [@config[:address]].flatten
        @options = [@config[:options]].flatten

        @address.reject!{ |i| i == nil or i == :undef }
        @options.reject!{ |i| i == nil or i == :undef }
      end

      def validate_config
        # compensate for puppet oddities
        @config.reject!{ |k,v| k == :undef or v == :undef }

        config_items = [
          :name,
          :desc,
          :address,
          :options
        ]

        required_items = [
          :name
        ]

        required_items.map {|k|
          unless @config.keys.include? k
            raise ArgumentError, "required config paramater #{k} not found"
          end
        }

        @config.each do |k,v|
          unless config_items.include? k
            raise ArgumentError, "unknown configuration item found: #{k}"
          end
        end
      end

      def options_string
        str = ""
        @options.each{|opt|
          str = [str,opt].join(' ')
        }
      end

      def get_hash
        @data
      end

      # Return a hash formatted for the create_resources() function
      # in puppet see shell_config resource
      def to_create_resources
        resources = {}

        @data.each_key {|topkey|

          # The top level key is the interface name
          ifname = topkey.to_sym

          @data[topkey][:addrs].each {|i|
            if i =~ /inet6 /
              key = "ifconfig_#{ifname}_ipv6"
            elsif i =~ /inet /
              key = "ifconfig_#{ifname}"
            end
            resources[key] = {
              "key"   => key,
              "value" => i,
            }
          }

          if @data[topkey][:aliases]
            @data[topkey][:aliases].each_with_index {|a,i|
              key = "ifconfig_#{ifname}_alias#{i}"
              resources[key] = {
                "key"   => key,
                "value" => a,
              }
            }
          end
        }

        resources
      end

      private

      def load_hash
        ifconfig = {}
        aliases  = []
        addrs    = []
        ip6set   = false
        ipset    = false

        process_addresses(@address) {|addr|
          if addr =~ /inet6 /
            if ip6set
              aliases << addr
            else
              addrs << addr
              ip6set = true
            end
          elsif addr =~ /inet /
            if ipset
              aliases << addr
            else
              addrs << addr
              ipset = true
            end
          else
            raise "unhandled address family"
          end
        }

        # append the options to the first address
        if addrs.size > 0
          ifconfig[:addrs] = addrs
          ifconfig[:addrs][0] = ( ifconfig[:addrs][0].split() + options_string()).join(' ')
        else
          ifconfig[:addrs] = options_string()
        end

        if aliases.size > 0
          ifconfig[:aliases] = aliases
        end

        {@name.to_sym => ifconfig}
      end

      def process_addresses(address=@address)
        address.each {|a|
          if a =~ /^DHCP/
            yield a
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
                raise "Value nont found"
              end
            end
          end
        }
      rescue
        raise "addr is #{a} of class #{a.class}: #{e.message}"
      end
    end
  end
end
