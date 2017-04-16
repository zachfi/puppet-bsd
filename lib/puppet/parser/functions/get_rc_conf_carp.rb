require 'puppet_x/bsd/rc_conf/carp'

module Puppet::Parser::Functions
  newfunction(:get_rc_conf_vlan,
              :type => :rvalue) do |args|

    config      = args.shift

    config_options = [:address,
     :id,
     :device,
     :advbase,
     :advskew,
     :pass,
    ]

    c           = {}

    config_options.each {|o|
      c[o] = config[o.to_s] if config[o.to_s]
    }

    return PuppetX::BSD::Rc_conf::Carp.new(c).values
  end
end
