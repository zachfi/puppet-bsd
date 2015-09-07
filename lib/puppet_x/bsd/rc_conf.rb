begin
  require 'ipaddress'
rescue => e
  puts e.message
  puts e.backtrace.inspect
end

require 'puppet_x/bsd/util'

module PuppetX
  module BSD
    class Rc_conf

      def initialize(config)
        @config = config
        ::PuppetX::BSD::Util.normalize_config(@config)

        optional_config_items = [
          :desc,
          :addresses,
          :options,
          :values
        ]

        required_config_items = [
          :name
        ]

        ::PuppetX::BSD::Util.validate_config(
          @config,
          required_config_items,
          optional_config_items
        )

        if @config[:values]
          if @config[:addresses]
            @config[:addresses].push(*@config[:values]).uniq!
          else
            @config[:addresses] = @config[:values]
          end
          Puppet.warning('Using the "values" parameter is deprecated, use "addresses" parameter instead')
        end


        # Ugly junk
        @name      = @config[:name]
        @desc      = @config[:desc]
        @addresses = [@config[:addresses]].flatten
        @options   = [@config[:options]].flatten
        @addresses.reject!{ |i| i == nil or i == :undef }
        @options.reject!{ |i| i == nil or i == :undef }

        # The blob
        @data = load_hash()
      end

      def options_string
        @options.join(' ')
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

          if @data[topkey][:addrs]
            if @data[topkey][:addrs].is_a? Array
              @data[topkey][:addrs].each {|i|
                if i =~ /inet6 /
                  key = "ifconfig_#{ifname}_ipv6"
                elsif i =~ /inet /
                  key = "ifconfig_#{ifname}"
                else
                  key = "ifconfig_#{ifname}"
                end
                resources[key] = {
                  "key"   => key,
                  "value" => i,
                }
              }
            else
              key = "ifconfig_#{ifname}"
              resources[key] = {
                "key"   => key,
                "value" => @data[topkey][:addrs],
              }
            end
          end

          if @data[topkey][:aliases] and @data[topkey][:aliases].is_a? Array
            @data[topkey][:aliases].each_with_index {|a,i|
              key = "ifconfig_#{ifname}_alias#{i}"
              resources[key] = {
                "key"   => key,
                "value" => a,
              }
            }
          end
        }

        Puppet.debug("Returning resources: #{resources}")

        resources
      end

      private

      # Load the ifconfig has that will contain all addresses (v4 and v6), and
      # alias addresses.
      def load_hash
        ifconfig = {}
        aliases  = []
        addrs    = []

        # Initially, the IP and IP6 has not been set.  This helps track whether
        # we are creating aliases or the first of the addresses.
        ip6set   = false
        ipset    = false

        process_addresses(@addresses) {|addr|
          if addr =~ /DHCP/
            addrs << addr
          elsif addr =~ /inet6 /
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

          if @options.size > 0
            ifconfig[:addrs][0] = [ifconfig[:addrs][0],options_string()].join(' ')
          end
        else
          if @options.size > 0
            ifconfig[:addrs] = options_string()
          end
        end

        if aliases.size > 0
          ifconfig[:aliases] = aliases
        end

        {@name.to_sym => ifconfig}
      end

      def process_addresses(addresses)
        addresses.each {|a|
          if a =~ /^(DHCP|dhcp)/
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
                raise "Value not found"
              end
            rescue Exception => e
              raise "addr is #{a} of class #{a.class}: #{e.message}"
            end
          end
        }
      end
    end
  end
end
