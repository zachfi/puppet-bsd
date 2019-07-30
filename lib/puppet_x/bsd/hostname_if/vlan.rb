# Module: PuppetX::HostnameIf::Vlan
#
# Responsible for processing the vlan(4) interfaces for hostname_if(5)
#

require_relative '../../../puppet_x/bsd/util'
require_relative '../../../puppet_x/bsd/hostname_if'
require_relative '../../../puppet_x/bsd/puppet_interface'
require_relative '../../../puppet_x/bsd/hostname_if/inet'

class HostnameIf::Vlan < PuppetX::BSD::PuppetInterface
  attr_reader :content

  def initialize(config)
    validation :id,
               :device

    options :address
    multiopts :address
    integers :id

    configure(config)
  end

  # Return an array of values to place on each line
  def values
    inet = []
    if @config[:address]
      PuppetX::BSD::HostnameIf::Inet.new(@config[:address]).process do |i|
        inet << i
      end
    end

    data = []
    data << vlan_string
    data << inet if inet
    data.flatten
  end

  def content
    values.join("\n")
  end

  def vlan_string
    vlanstring = []
    if @config[:id].to_i < 1 || @config[:id].to_i > 4094
      raise ArgumentError, "invalid vlan ID: #{@config[:id]}"
    end
    vlanstring << 'vlan' << @config[:id]
    vlanstring << 'vlandev' << @config[:device]
    vlanstring.join(' ')
  end
end
