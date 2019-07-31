require_relative 'util'

module PuppetX
  module BSD
    class Ifconfig
      attr_reader :interfaces

      def initialize(output)
        @output = output
        @interfaces = @output.scan(%r{^\S+}).map { |i| i.sub(%r{:$}, '') }.uniq
      end

      def parse
        data = {}
        parse_interface_lines(@output) do |i|
          data = PuppetX::BSD::Util.uber_merge(data, i)
        end
        data
      end

      def parse_interface_lines(output)
        curint = nil
        output.lines do |line|
          line.chomp!

          # This should match a line in the output of ifconfig that represents
          # the brignning of an interface block.
          if line =~ %r{^\S+\d+:}
            lineparts = line.split(%r{ }, 2)
            curint = %r{(^\S+\d+):}.match(lineparts[0])[1].to_sym
            parse_interface_tokens(lineparts[1]) do |t|
              d = { curint => t }
              yield d
            end
          end

          if curint
            parse_interface_tokens(line.strip) do |t|
              d = { curint => t }
              yield d
            end
          end
        end
      end

      # flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 32768
      def parse_interface_tokens(tokenstring)
        case tokenstring
        when %r{^flags=[[:xdigit:]]+<.*>}
          flagstring, remain = tokenstring.split(%r{ }, 2)
          flags = %r{<(.*)>}.match(flagstring)[1].split(',')
          unless flags.empty?
            d = { flags: flags }
            yield d
          end
          if remain
            parse_interface_tokens(remain) do |t|
              yield t
            end
            remain = nil
          end
        when %r{^metric\s+\d+}
          metric, remain = %r{metric\s+(\d+)\s*(.*)}.match(tokenstring)[1, 2]
          d = { metric: metric }
          yield d
          if remain
            parse_interface_tokens(remain) do |t|
              yield t
            end
            remain = nil
          end
        when %r{^mtu\s+\d+}
          mtu, remain = %r{mtu\s+(\d+)\s*(.*)}.match(tokenstring)[1, 2]
          d = { mtu: mtu }
          yield d
          if remain
            parse_interface_tokens(remain) do |t|
              yield t
            end
            remain = nil
          end
        when %r{^inet6\s+}
          address = %r{inet6\s+([0-9a-fA-F:]+)%?}.match(tokenstring)[1]
          prefix = %r{prefixlen\s+(\d+)}.match(tokenstring)[1]
          d = { inet6: address + '/' + prefix }
          yield d
        when %r{^inet\s+}
          address = %r{inet\s+((?:\d{1,3}\.){3}\d{1,3})%?}.match(tokenstring)[1]
          octnetmask = %r{netmask\s+0x([0-9a-fA-F]{8})}.match(tokenstring)[1]
          masklist = []
          octnetmask.split(%r{}).each_slice(2) do |i|
            masklist << Integer("0x#{i.join}")
          end
          netmask = masklist.join('.')
          d = { inet: address + '/' + netmask }
          yield d
        end
      end
    end
  end
end
