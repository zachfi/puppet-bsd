module PuppetX
  module BSD
    class Util
      def self.normalize_config(config)
        # Modify the config object to reject all undef values
        raise ArgumentError, 'Config object must be a Hash' unless config.is_a? Hash
        config.reject! { |k, v| (k == :undef) || (v == :undef) }
        config.reject! { |k, v| (k == :nil) || (v == :nil) }
      end

      def self.validate_config(config, required_items, optional_items)
        # Ensure that all of the required params are passed, and that the rest
        # of the options requested are valid
        raise ArgumentError, 'Config object must be a Hash' unless config.is_a? Hash
        required_items.each do |k, _v|
          unless config.keys.include? k
            raise ArgumentError, "#{k} is a required configuration item"
          end
        end

        config.each do |k, _v|
          unless required_items.include?(k) || optional_items.include?(k)
            raise ArgumentError, "unknown configuration item found: #{k}"
          end
        end
      end

      def self.uber_merge(h1, h2)
        h2.keys.each do |key|
          # Move the keys that won't clobber from h2 to h1
          unless h1.keys.include? key
            h1[key] = h2[key]
            h2.delete(key)
          end
        end

        h1.keys.each do |key|
          # Move more complicated keys from h2 to h1
          next unless h2.keys.include? key

          if h1[key].is_a?(Hash) && h2[key].is_a?(Hash)
            h1[key] = uber_merge(h1[key], h2[key])
            next
          elsif h1[key].is_a? Array
            h1[key] << h2[key]
            h1[key].flatten!
            next
          else
            # key values conflict and should be combined
            unless h1[key] == h2[key]
              h1[key] = Array([h1[key], h2[key]]).flatten
            end
          end
        end

        h1
      end
    end
  end
end
