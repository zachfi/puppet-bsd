# Module: PuppetX::Hostname_if::Pfsync
#
# Responsible for processing the pfsync(4) interfaces for hostname_if(5)
#
require_relative '../../../puppet_x/bsd/util'
require_relative '../../../puppet_x/bsd/hostname_if/inet'

module PuppetX
  module BSD
    class Hostname_if
      class Pfsync

        attr_reader :content

        def initialize(config)
          @config = config
          ::PuppetX::BSD::Util.normalize_config(@config)

          required_config_items = []

          optional_config_items = [
            :syncdev,
            :syncpeer,
            :maxupd,
            :defer,
          ]

          ::PuppetX::BSD::Util.validate_config(
            @config,
            required_config_items,
            optional_config_items
          )
        end

        def values
          data = []
          data << pfsync_string
          data.flatten
        end

        def content
          values.join("\n")
        end

        def pfsync_string
          pfsyncstring = []
          if @config[:syncdev]
            pfsyncstring << 'syncdev' << @config[:syncdev]
          else
            pfsyncstring << '-syncdev'
          end

          if @config[:syncpeer]
            pfsyncstring << 'syncpeer' << @config[:syncpeer]
          else
            pfsyncstring << '-syncpeer'
          end

          if @config[:maxupd]
            if @config[:maxupd].to_i < 0 or @config[:maxupd].to_i > 255
              raise ArgumentError, 'value of maxupd has to be in the range of 0 and 255'
            end
            pfsyncstring << 'maxupd' << @config[:maxupd]
          else
            pfsyncstring << 'maxupd' << '128'
          end

          if @config[:defer] == true
            pfsyncstring << 'defer'
          else
            pfsyncstring << '-defer'
          end

          pfsyncstring.join(' ')
        end
      end
    end
  end
end

