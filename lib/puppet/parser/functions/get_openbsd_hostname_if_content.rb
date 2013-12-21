require 'puppet_x/bsd/hostname_if'

module Puppet::Parser::Functions
  newfunction(:get_openbsd_hostname_if_content,
              :type => :rvalue) do |args|

    config        = args.shift

    c = {}
    c[:desc]     = config["description"] if config["description"]
    c[:values]   = config["values"] if config["values"]
    c[:options]  = config["options"] if config["options"]

    hostname_if = PuppetX::BSD::Hostname_if.new(c)
    return hostname_if.content
  end
end
