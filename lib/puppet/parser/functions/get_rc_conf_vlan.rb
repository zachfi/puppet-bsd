require_relative '../../../puppet_x/bsd/rc_conf/vlan'

module Puppet::Parser::Functions
  newfunction(:get_rc_conf_vlan,
              :type => :rvalue) do |args|

    config      = args.shift

    c           = {}
    c[:id]      = config["id"] if config["id"]
    c[:device]  = config["device"] if config["device"]
    c[:address] = config["address"] if config["address"]

    return PuppetX::BSD::Rc_conf::Vlan.new(c).values
  end
end
