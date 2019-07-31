# Module: PuppetX::RcConf::Trunk
#
# Responsible for processing the lagg(4) interfaces for rc.conf(5)
#
require_relative '../rc_conf'

class Trunk < RcConf
  def initialize(config)
    validation :interface,
               :proto

    options :interface,
            :address
    multiopts :interface,
              :address

    configure(config)
  end

  # NOTE: the addresses are not processed here due to the calling function and
  # define for bsd::network::interface::trunk passing 'address' directly to the
  # bsd::network::interface define.
  def trunk_values
    data = []
    data << 'laggproto ' + @config[:proto]
    Array(config[:interface]).flatten.each do |i|
      data << 'laggport ' + i
    end

    data
  end

  def content
    trunk_values.join(' ')
  end
end
