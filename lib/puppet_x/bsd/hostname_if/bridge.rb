# Module: PuppetX::HostnameIf::Bridge
#
# Responsible for processing the bridge(4) interfaces for hostname_if(5)
# on OpenBSD.
#
require_relative '../../../puppet_x/bsd/hostname_if'
require_relative '../../../puppet_x/bsd/puppet_interface'

class HostnameIf::Bridge < PuppetX::BSD::PuppetInterface
  attr_reader :content

  def initialize(config)
    validation :interface
    multiopts :interface

    configure(config)
  end

  def content
    @config[:interface].map { |i| "add #{i}" }
  end
end
