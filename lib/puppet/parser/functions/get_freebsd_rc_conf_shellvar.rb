require_relative '../../../puppet_x/bsd/rc_conf'

module Puppet::Parser::Functions
  newfunction(:get_freebsd_rc_conf_shellvar,
              :type => :rvalue) do |args|

    config = args.shift

    c = {}
    c[:name]      = config["name"] if config["name"]
    c[:desc]      = config["description"] if config["description"]
    c[:addresses] = config["addresses"] if config["addresses"]
    c[:options]   = config["options"] if config["options"]
    c[:values]    = config["values"] if config["values"]

    return PuppetX::BSD::Rc_conf.new(c).to_create_resources
  end
end
