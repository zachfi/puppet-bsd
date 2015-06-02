# Module: PuppetX::Rc_conf::Vlan
#
# Responsible for processing the vlan(4) interfaces for rc.conf(5)
#

#require 'puppet_x/bsd/hostname_if/inet'

module PuppetX
  module BSD
    class Rc_conf
      class Vlan

        attr_reader :content

        def initialize(config)
          @config = config
          validate_config()
        end

        def validate_config

          # compensate for puppet oddities
          @config.reject!{ |k,v|
            k == :undef or v == :undef or v.to_s.length == 0
          }

          required_config_items = [
            :id,
            :device,
          ]

          available_config_items = [
            :address,
          ]

          # verify we have the required configuration items
          required_config_items.each do |k,v|
            unless @config.keys.include? k
              raise ArgumentError, "#{k} is a required configuration item"
            end
          end

          @config.each do |k,v|
            all_options = [available_config_items,required_config_items].flatten
            unless all_options.include? k
              raise ArgumentError, "unknown configuration item found: #{k}"
            end
          end
        end

        # Return an array of parsed values
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
