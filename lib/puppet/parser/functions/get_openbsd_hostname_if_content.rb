require_relative '../../../puppet_x/bsd/hostname_if'

module Puppet::Parser::Functions
  newfunction(:get_openbsd_hostname_if_content,
              type: :rvalue) do |args|

    config = args.shift

    c = {}
    c[:type]       = config['type'] if config['type']
    c[:desc]       = config['description'] if config['description']
    c[:addresses]  = config['addresses'] if config['addresses']
    c[:raw_values] = config['raw_values'] if config['raw_values']
    c[:options]    = config['options'] if config['options']
    c[:mtu]        = config['mtu'] if config['mtu']

    return Hostname_if.new(c).content
  end
end
