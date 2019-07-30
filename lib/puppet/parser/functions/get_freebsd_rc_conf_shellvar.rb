require_relative '../../../puppet_x/bsd/rc_conf'

module Puppet::Parser::Functions
  newfunction(:get_freebsd_rc_conf_shellvar,
              type: :rvalue) do |args|

    config = args.shift

    c = {}
    c[:name]       = config['name'] if config['name']
    c[:desc]       = config['description'] if config['description']
    c[:addresses]  = config['addresses'] if config['addresses']
    c[:raw_values] = config['raw_values'] if config['raw_values']
    c[:options]    = config['options'] if config['options']
    c[:mtu]        = config['mtu'] if config['mtu']

    return RcConf.new(c).to_create_resources
  end
end
