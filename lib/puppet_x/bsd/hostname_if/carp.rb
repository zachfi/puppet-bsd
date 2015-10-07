# Module: PuppetX::Hostname_if::Carp
#
# Responsible for processing the carp(4) interfaces for hostname_if(5)
#
require 'puppet_x/bsd/util'
require 'puppet_x/bsd/hostname_if/inet'

module PuppetX
  module BSD
    class Hostname_if
      class Carp

        attr_reader :content

        def initialize(config)
          @config = config
          ::PuppetX::BSD::Util.normalize_config(@config)

          required_config_items = [
            :id,
            :address,
            :device,
          ]

          optional_config_items = [
            :advbase,
            :advskew,
            :carpdev,
            :pass,
          ]

          ::PuppetX::BSD::Util.validate_config(
            @config,
            required_config_items,
            optional_config_items
          )
        end

        def content
          inet  = []
          PuppetX::BSD::Hostname_if::Inet.new(@config[:address]).process {|i|
            inet << i
          }

          data = []
          data << carp_string()
          data << inet if inet
          data.join("\n")
        end

        def carp_string
          carpstring = []
          carpstring << 'vhid' << @config[:id]
          carpstring << 'pass' << @config[:pass] if @config[:pass]
          carpstring << 'carpdev' << @config[:device]
          carpstring << 'advbase' << @config[:advbase] if @config[:advbase]
          carpstring << 'advskew' << @config[:advskew] if @config[:advskew]
          carpstring.join(' ')
        end
      end
    end
  end
end
