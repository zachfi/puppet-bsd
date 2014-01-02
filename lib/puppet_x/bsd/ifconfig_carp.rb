module PuppetX
  module BSD
    class Ifconfig_carp

      attr_reader :content

      def initialize(config)
        @config = config
        validate_config()
      end

      def validate_config

        # compensate for puppet oddities
        @config.reject!{ |k,v| k == :undef or v == :undef }

        required_config_items = [
          :vhid,
          :address,
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
        ]

        @config.each do |k,v|
          unless required_config_items.include? k or optional_config_items.include? k
            raise ArgumentError, "unknown configuration item found: #{k}"
          end
        end

      end

      def content

        data = []

        data << @config[:address] if @config[:address]
        data << 'vhid' << @config[:vhid] if @config[:vhid]
        data << 'advbase' << @config[:advbase] if @config[:advbase]
        data << 'advskew' << @config[:advskew] if @config[:advskew]
        data << 'carpdev' << @config[:carpdev] if @config[:carpdev]

        data.join(' ')
      end

    end
  end
end
