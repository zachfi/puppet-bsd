require_relative '../../../puppet_x/bsd/rc_conf/bridge'

module Puppet::Parser::Functions
  newfunction(:get_rc_conf_bridge,
              type: :rvalue) do |args|

    config        = args.shift

    c             = {}
    c[:interface] = config['interface'] if config['interface']

    return Bridge.new(c).bridge_values
  end
end
