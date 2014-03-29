# Module: PuppetX::Hostname_if::Vlan
#
# Responsible for processing the vlan(4) interfaces for hostname_if(5)
#

require 'puppet_x/bsd/hostname_if/inet'

module PuppetX
  module BSD
    class Hostname_if
      class Vlan

        attr_reader :content

        def initialize(config)
          @config = config
          validate_config()
        end

        def validate_config

          # compensate for puppet oddities
          @config.reject!{ |k,v| k == :undef or v == :undef }

          required_config_items = [
            :id,
            :address,
            :device,
          ]

          # verify we have the required configuration items
          required_config_items.each do |k,v|
            unless @config.keys.include? k
              raise ArgumentError, "#{k} is a required configuration item"
            end
          end

          @config.each do |k,v|
            unless required_config_items.include? k
              raise ArgumentError, "unknown configuration item found: #{k}"
            end
          end
        end

        def content
          inet  = []
          PuppetX::BSD::Hostname_if::Inet.new(@config[:address]).process {|i|
            inet << i
          }

          data = []
          data << vlan_string()
          data << inet if inet
          data.join("\n")
        end

        def vlan_string
          vlanstring = []
          vlanstring << 'vlan' << @config[:id]
          vlanstring << 'vlandev' << @config[:device]
          vlanstring.join(' ')
        end
      end
    end
  end
end
