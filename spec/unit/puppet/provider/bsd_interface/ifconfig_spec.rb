require 'spec_helper'
require 'puppet/provider/bsd_interface/ifconfig'

type_class = Puppet::Type.type(:bsd_interface)
provider_class = Puppet::Type.type(:bsd_interface).provider(:ifconfig)

describe provider_class do
  let(:ifconfig) { 'ifconfig' }

  let(:vlan_interface) do
    Puppet::Type.type(:bsd_interface).new(:name => 'vlan0', :provider => 'ifconfig')
  end

  let(:em_interface) do
    Puppet::Type.type(:bsd_interface).new(:name => 'em0', :provider => 'ifconfig')
  end

  let (:provider) { resource.provider }

  before do
    expect(provider_class).to receive(:ifconfig).with(['-C']) { 'vlan pflog0' }
  end

  context "#destroy" do
    it "should destroy a pseudo interface" do
      expect(provider_class).to receive(:ifconfig).with(['vlan0', 'down'])
      expect(provider_class).to receive(:ifconfig).with(['vlan0', 'destroy'])
      vlan_interface.provider.destroy
    end

    it "should destroy a real interface" do
      expect(provider_class).to receive(:ifconfig).with(['em0', 'down'])
      expect(provider_class).to_not receive(:ifconfig).with(['em0', 'destroy'])
      em_interface.provider.destroy
    end
  end

  context "#create" do
    it "should create a pseudo interface" do
      expect(provider_class).to receive(:ifconfig).with(['vlan0', 'create'])
      expect(provider_class).to receive(:ifconfig).with(['vlan0', 'up'])
      vlan_interface.provider.create
    end

    it "should create a real interface" do
      expect(provider_class).to_not receive(:ifconfig).with(['em0', 'create'])
      expect(provider_class).to receive(:ifconfig).with(['em0', 'up'])
      em_interface.provider.create
    end
  end
end
