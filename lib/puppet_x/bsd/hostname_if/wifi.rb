# Module: PuppetX::Hostname_if::Wifi
#
# Responsible for processing the Wifi interfaces for hostname_if(5)
#
require 'puppet_x/bsd/util'
require 'puppet_x/bsd/hostname_if/inet'

module PuppetX
  module BSD
    class Hostname_if
      class Wifi

        attr_reader :content

        def initialize(config)
          @config = config
          ::PuppetX::BSD::Util.normalize_config(@config)
          required_config_items = [
            :network_name,
            :network_key,
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

        def content
          data = []

          if @config[:address]
            inet = []
            PuppetX::BSD::Hostname_if::Inet.new(@config[:address]).process {|i|
              inet << i
            }
            data << inet
          end

          data << ['nwid',@config[:network_name]].join(' ')
          data << ['wpakey',@config[:network_key]].join(' ')
          data.join(' ')
        end
      end
    end
  end
end
