require_relative '../../../puppet_x/bsd/hostname_if/wifi'

module Puppet::Parser::Functions
  newfunction(:get_hostname_if_wifi,
              :type => :rvalue) do |args|

    config = args.shift

    c = {}
    c[:network_name] = config["network_name"]
    c[:network_key]  = config["network_key"] if config["network_key"]
    c[:address]      = config["address"] if config["address"]

    return PuppetX::BSD::Hostname_if::Wifi.new(c).content
  end
end


