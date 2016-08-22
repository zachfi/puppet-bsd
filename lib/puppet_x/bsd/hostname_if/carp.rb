# Module: PuppetX::Hostname_if::Carp
#
# Responsible for processing the carp(4) interfaces for hostname_if(5)
#
require_relative '../../../puppet_x/bsd/hostname_if'
require_relative '../../../puppet_x/bsd/puppet_interface'
require_relative '../../../puppet_x/bsd/hostname_if/inet'

class Hostname_if::Carp < PuppetX::BSD::PuppetInterface
  attr_reader :content

  def initialize(config)
    validation :id,
      :address,
      :device

    multiopts :address

    options :advbase,
      :advskew,
      :carpdev,
      :pass

    configure(config)
  end

  def content
    inet = []
    PuppetX::BSD::Hostname_if::Inet.new(@config[:address]).process {|i|
      inet << i
    }

    data = []
    data << carp_string()
    data << inet if inet
    data.join("\n")
  end

  def carp_string
    carpstring = []
    carpstring << 'vhid' << @config[:id]
    carpstring << 'pass' << @config[:pass] if @config[:pass]
    carpstring << 'carpdev' << @config[:device]
    carpstring << 'advbase' << @config[:advbase] if @config[:advbase]
    carpstring << 'advskew' << @config[:advskew] if @config[:advskew]
    carpstring.join(' ')
  end
end
