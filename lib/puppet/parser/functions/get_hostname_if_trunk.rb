require_relative '../../../puppet_x/bsd/hostname_if/trunk'

module Puppet::Parser::Functions
  newfunction(:get_hostname_if_trunk,
              type: :rvalue) do |args|

    config = args.shift

    c = {}
    c[:interface] = config['interface']
    c[:proto]     = config['proto']
    c[:address]   = config['address'] if config['address']

    return Hostname_if::Trunk.new(c).content
  end
end
