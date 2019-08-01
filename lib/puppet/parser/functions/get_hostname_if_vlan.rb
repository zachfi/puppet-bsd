require_relative '../../../puppet_x/bsd/hostname_if/vlan'

module Puppet::Parser::Functions
  newfunction(:get_hostname_if_vlan,
              type: :rvalue) do |args|

    config      = args.shift

    c           = {}
    c[:id]      = config['id'] if config['id']
    c[:address] = config['address'] if config['address']
    c[:device]  = config['device'] if config['device']

    return Hostname_if::Vlan.new(c).content
  end
end
