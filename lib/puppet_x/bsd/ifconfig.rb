require_relative 'util'

module PuppetX
  module BSD
    class Ifconfig
      attr_reader :interfaces

      def initialize(output)
        @output = output
        @interfaces = @output.scan(/^\S+/).collect { |i| i.sub(/:$/, '') }.uniq
      end

      def parse
        data = {}
        parse_interface_lines(@output) {|i|
          data = PuppetX::BSD::Util.uber_merge(data, i)
        }
        data
      end

      def parse_interface_lines(output)
        curint = nil
        output.lines {|line|
          line.chomp!

          # This should match a line in the output of ifconfig that represents
          # the brignning of an interface block.
          if line =~ /^\S+\d+:/
            lineparts = line.split(/ /, 2)
            curint = /(^\S+\d+):/.match(lineparts[0])[1].to_sym
            parse_interface_tokens(lineparts[1]) {|t|
              yield ({curint => t})
            }
          end

          if curint
            parse_interface_tokens(line.strip) {|t|
              yield ({curint => t})
            }
          end
        }
      end

      # flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> mtu 32768
      def parse_interface_tokens(tokenstring)
        case tokenstring
        when /^flags=[[:xdigit:]]+<.*>/
          flagstring, remain = tokenstring.split(/ /, 2)
          flags = /<(.*)>/.match(flagstring)[1].split(',')
          if flags.size > 0
            yield ({:flags => flags})
          end
          if remain
            parse_interface_tokens(remain) {|t|
              yield (t)
            }
            remain = nil
          end
        when /^metric\s+\d+/
          metric, remain = /metric\s+(\d+)\s*(.*)/.match(tokenstring)[1,2]
          yield ({:metric => metric})
          if remain
            parse_interface_tokens(remain) {|t|
              yield (t)
            }
            remain = nil
          end
        when /^mtu\s+\d+/
          mtu, remain = /mtu\s+(\d+)\s*(.*)/.match(tokenstring)[1,2]
          yield ({:mtu => mtu})
          if remain
            parse_interface_tokens(remain) {|t|
              yield (t)
            }
            remain = nil
          end
        when /^inet6\s+/
          address = /inet6\s+([0-9a-fA-F:]+)%?/.match(tokenstring)[1]
          prefix = /prefixlen\s+(\d+)/.match(tokenstring)[1]
          yield ({:inet6 => address + '/' + prefix})
        when /^inet\s+/
          address = /inet\s+((?:\d{1,3}\.){3}\d{1,3})%?/.match(tokenstring)[1]
          octnetmask = /netmask\s+0x([0-9a-fA-F]{8})/.match(tokenstring)[1]
          masklist = []
          octnetmask.split(//).each_slice(2) {|i|
            masklist <<  Integer("0x#{i.join()}")
          }
          netmask = masklist.join('.')
          yield ({:inet => address + '/' + netmask})
        end

      end
    end
  end
end
