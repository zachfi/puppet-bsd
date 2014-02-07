require 'puppet_x/bsd/rc_conf'

module Puppet::Parser::Functions
  newfunction(:get_freebsd_rc_conf_shellconfig,
              :type => :rvalue) do |args|

    config = args.shift

    c = {}
    c[:name]    = config["name"] if config["name"]
    c[:desc]    = config["description"] if config["description"]
    c[:address] = config["values"] if config["values"]
    c[:options] = config["options"] if config["options"]

    return PuppetX::BSD::Rc_conf.new(c).to_create_resources
  end
end
