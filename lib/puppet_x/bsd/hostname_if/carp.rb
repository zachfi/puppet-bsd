# Module: PuppetX::Hostname_if::Carp
#
# Responsible for processing the carp(4) interfaces for hostname_if(5)
#
require 'puppet_x/bsd/hostname_if/inet'

module PuppetX
  module BSD
    class Hostname_if
      class Carp

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

          optional_config_items = [
            :advbase,
            :advskew,
            :carpdev,
            :pass,
          ]

          @config.each do |k,v|
            unless required_config_items.include? k or optional_config_items.include? k
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
          data << inet
          data << carp_string()
          data.join(' ')
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
