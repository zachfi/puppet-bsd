# Module: PuppetX::Hostname_if::Wifi
#
# Responsible for processing the Wifi interfaces for hostname_if(5)
#
require_relative '../../../puppet_x/bsd/hostname_if'
require_relative '../../../puppet_x/bsd/hostname_if/inet'
require_relative '../../../puppet_x/bsd/puppet_interface'

class Hostname_if::Wifi < PuppetX::BSD::PuppetInterface
  attr_reader :content

  def initialize(config)
    validation :network_name
    options :address,
            :wpa_key
    multiopts :address

    configure(config)
  end

  def content
    data = []

    if @config[:address]
      inet = []
      PuppetX::BSD::Hostname_if::Inet.new(@config[:address]).process do |i|
        inet << i
      end
      data << inet
    end

    data << wifi_string
    data.join("\n")
  end

  def wifi_string
    wifistring = []
    wifistring << 'nwid' << @config[:network_name]
    wifistring << 'wpakey' << @config[:wpa_key] if @config[:wpa_key]
    wifistring.join(' ')
  end
end
