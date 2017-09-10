# Module: PuppetX::Rc_conf::Vlan
#
# Responsible for processing the vlan(4) interfaces for rc.conf(5)
#
require_relative '../rc_conf'

class Vlan < Rc_conf
  def initialize(config)
    validation :device,
               :id

    options :address
    multiopts :address
    integers :id

    configure(config)
  end

  # Return an array of parsed vlan values

  # NOTE: the addresses are not processed here due to the calling function and
  # define for bsd::network::interface::vlan passing 'address' directly to the
  # bsd::network::interface define.
  def vlan_values
    data = []
    data << 'vlan ' + @config[:id].to_s
    data << 'vlandev ' + @config[:device]
    data.flatten
  end

  def content
    vlan_values.join(' ')
  end
end
