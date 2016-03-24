require_relative '../../../puppet_x/bsd/hostname_if'

module Puppet::Parser::Functions
  newfunction(:get_openbsd_hostname_if_content,
              :type => :rvalue) do |args|

    config       = args.shift

    c = {}
    c[:type]      = config["type"]
    c[:desc]      = config["description"] if config["description"]
    c[:addresses] = config["addresses"] if config["addresses"]
    c[:values]    = config["values"] if config["values"]
    c[:options]   = config["options"] if config["options"]

    return PuppetX::BSD::Hostname_if.new(c).content
  end
end
