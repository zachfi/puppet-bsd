require_relative '../../../puppet_x/bsd/hostname_if/wifi'

module Puppet::Parser::Functions
  newfunction(:get_hostname_if_wifi,
              type: :rvalue) do |args|

    config = args.shift

    c = {}
    c[:network_name] = config['network_name']
    c[:wpa_key]      = config['wpa_key'] if config['wpa_key']
    c[:address]      = config['address'] if config['address']

    return Hostname_if::Wifi.new(c).content
  end
end
