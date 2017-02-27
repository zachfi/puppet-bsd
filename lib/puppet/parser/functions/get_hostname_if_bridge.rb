require_relative '../../../puppet_x/bsd/hostname_if/bridge'

module Puppet::Parser::Functions
  newfunction(:get_hostname_if_bridge,
              type: :rvalue) do |args|

    config = args.shift

    c = {}
    c[:interface] = config['interface']

    return Hostname_if::Bridge.new(c).content
  end
end
