require_relative '../../../puppet_x/bsd/rc_conf/trunk'

module Puppet::Parser::Functions
  newfunction(:get_rc_conf_trunk,
              type: :rvalue) do |args|

    config = args.shift

    c             = {}
    c[:interface] = config['interface'] if config['interface']
    c[:proto]     = config['proto'] if config['proto']
    c[:address]   = config['address'] if config['address']

    return Trunk.new(c).trunk_values
  end
end
