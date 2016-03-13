# Module: PuppetX::Hostname_if::Wifi
#
# Responsible for processing the Wifi interfaces for hostname_if(5)
#
require_relative '../../../puppet_x/bsd/util'
require_relative '../../../puppet_x/bsd/hostname_if/inet'

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
          ]

          optional_config_items = [
            :address,
            :network_key,
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

          data << wifi_string()
          data.join("\n")
        end

        def wifi_string
          wifistring = []
          wifistring << 'nwid' << @config[:network_name]
          wifistring << 'wpakey' << @config[:network_key] if @config[:network_key]
          wifistring.join(' ')
        end
      end
    end
  end
end
