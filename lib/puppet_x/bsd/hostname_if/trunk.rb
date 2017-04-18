# Module: PuppetX::Hostname_if::Trunk
#
# Responsible for processing the trunk(4) interfaces for hostname_if(5)
#
require_relative '../../../puppet_x/bsd/hostname_if'
require_relative '../../../puppet_x/bsd/puppet_interface'
require_relative '../../../puppet_x/bsd/hostname_if/inet'

class Hostname_if::Trunk < PuppetX::BSD::PuppetInterface
  attr_reader :content

  def initialize(config)
    validation :interface,
               :proto

    options :interface,
            :address
    multiopts :interface,
              :address

    configure(config)
  end

  def values
    inet = []
    if @config[:address]
      PuppetX::BSD::Hostname_if::Inet.new(@config[:address]).process do |i|
        inet << i
      end
    end

    data = []
    data << trunk_string
    data << inet if inet
    data.flatten
  end

  def content
    values.join("\n")
  end

  def trunk_string
    trunkstring = []

    unless %w(broadcast failover lacp loadbalance none roundrobin).include? @config[:proto]
      raise ArgumentError, "invalid trunk protocol: #{@config[:proto]}"
    end
    trunkstring << 'trunkproto' << @config[:proto]

    if @config[:interface].is_a? Array
      @config[:interface].each do |i|
        trunkstring << 'trunkport' << i
      end
    elsif @config[:interface].is_a? String
      trunkstring << 'trunkport' << @config[:interface]
    end

    trunkstring.join(' ')
  end
end
