# Module: PuppetX::Hostname_if::Vlan
#
# Responsible for processing the vlan(4) interfaces for hostname_if(5)
#

require 'puppet_x/bsd/util'
require 'puppet_x/bsd/hostname_if/inet'

module PuppetX
  module BSD
    class Hostname_if
      class Vlan

        attr_reader :content

        def initialize(config)
          @config = config
          ::PuppetX::BSD::Util.normalize_config(@config)

          required_config_items = [
            :id,
            :device,
          ]

          optional_config_items = [
            :address,
          ]

          ::PuppetX::BSD::Util.validate_config(
            @config,
            required_config_items,
            optional_config_items
          )
        end

        # Return an array of values to place on each line
        def values
          inet  = []
          if @config[:address]
            PuppetX::BSD::Hostname_if::Inet.new(@config[:address]).process {|i|
              inet << i
            }
          end

          data = []
          data << vlan_string()
          data << inet if inet
          data.flatten
        end

        def content
          values().join("\n")
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
