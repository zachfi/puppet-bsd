# Module: PuppetX::RcConf::Bridge
#
# Responsible for processing the bridge(4) interfaces for rc.conf(5)
#
require_relative '../rc_conf'

class Bridge < RcConf
  def initialize(config)
    validation :interface

    multiopts :interface

    configure(config)
  end

  def bridge_values
    data = []

    if @config[:interface]
      @config[:interface].each do |i|
        data << 'addm ' + i
      end
    end

    data.flatten
  end

  def content
    bridge_vlaues.join(' ')
  end
end
