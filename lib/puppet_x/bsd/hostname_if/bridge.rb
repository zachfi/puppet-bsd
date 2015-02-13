# Module: PuppetX::Hostname_if::Bridge
#
# Responsible for processing the bridge(4) interfaces for hostname_if(5)
#
require 'puppet_x/bsd/util'
require 'puppet_x/bsd/hostname_if/inet'

module PuppetX
  module BSD
    class Hostname_if
      class Bridge

        attr_reader :content

        def initialize(config)
          @config = config
          ::PuppetX::BSD::Util.normalize_config(@config)
          required_config_items = [
            :interface,
          ]

          optional_config_items = [
          ]

          ::PuppetX::BSD::Util.validate_config(
            @config,
            required_config_items,
            optional_config_items
          )
        end

        def content
          data = []
          Array(@config[:interface]).flatten.each {|i|
            data << "add #{i}"
          }
          return data
        end
      end
    end
  end
end
