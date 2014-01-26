# Module: PuppetX::Hostname_if::Trunk
#
# Responsible for processing the trunk(4) interfaces for hostname_if(5)
#

module PuppetX
  module BSD
    class Hostname_if
      class Trunk

        attr_reader :content

        def initialize(config)
          @config = config
          validate_config()
        end

        def validate_config

          # compensate for puppet oddities
          @config.reject!{ |k,v| k == :undef or v == :undef }

          required_config_items = [
            :interface,
            :proto,
          ]

          # verify we have the required configuration items
          required_config_items.each do |k,v|
            unless @config.keys.include? k
              raise ArgumentError, "#{k} is a required configuration item"
            end
          end

          optional_config_items = [
            :address,
          ]

          @config.each do |k,v|
            unless required_config_items.include? k or optional_config_items.include? k
              raise ArgumentError, "unknown configuration item found: #{k}"
            end
          end
        end

        def content
          data = []
          data << trunk_string()
          data.join(' ')
        end

        def trunk_string
          trunkstring = []
          trunkstring << 'trunkproto' << @config[:proto]

          if @config[:interface].is_a? Array
            @config[:interface].each {|i|
              trunkstring << 'trunkport' << i
            }
          elsif @config[:interface].is_a? String
              trunkstring << 'trunkport' << @config[:interface]
          end

          trunkstring.join(' ')
        end
      end
    end
  end
end

