# Module: PuppetX::Hostname_if::Bridge
#
# Responsible for processing the bridge(4) interfaces for hostname_if(5)
#
require_relative '../../../puppet_x/bsd/hostname_if/inet'
require_relative '../../../puppet_x/bsd'
require_relative '../../../puppet_x/bsd/puppet_interface'

class PuppetX::BSD::Hostname_if::Bridge < PuppetX::BSD::PuppetInterface

  attr_reader :content

  def initialize(config)
    validation :interface
    multiopts :interface

    configure(config)
  end

  def content
    @config[:interface].map {|i| "add #{i}" }
  end
end
