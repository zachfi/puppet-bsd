require 'puppet_x/bsd/ifconfig_carp'

module Puppet::Parser::Functions
  newfunction(:get_carp_ifconfig,
              :type => :rvalue) do |args|

    config       = args.shift

    c = {}
    c[:vhid]    = config["vhid"] if config["vhid"]
    c[:address] = config["address"] if config["address"]
    c[:advbase] = config["advbase"] if config["advbase"]
    c[:advskew] = config["advskew"] if config["advskew"]
    c[:carpdev] = config["carpdev"] if config["carpdev"]

    return PuppetX::BSD::Ifconfig_carp.new(c).content
  end
end
