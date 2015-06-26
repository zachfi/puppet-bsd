# Module: PuppetX::Rc_conf::Vlan
#
# Responsible for processing the vlan(4) interfaces for rc.conf(5)
#
require 'puppet_x/bsd/util'

module PuppetX
  module BSD
    class Rc_conf
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

        # Return an array of parsed vlan values

        # NOTE: the addresses are not processed here due to the
        # calling function and define for
        # bsd::network::interface::vlan passnig 'address' directly to
        # the bsd::network::interface define.
        def values
          data = []
          data << 'vlan ' + @config[:id].to_s
          data << 'vlandev ' + @config[:device]
          data.flatten
        end

        def content
          values().join(" ")
        end
      end
    end
  end
end
