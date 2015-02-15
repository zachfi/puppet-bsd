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

  context "#destroy" do
    before do
      expect(provider_class).to receive(:ifconfig).with(['-C']) { 'vlan pflog0' }
    end

    context "when created" do
      it "should destroy a pseudo interface" do
        expect(provider_class).to receive(:ifconfig).with(['vlan0', 'down'])
        expect(provider_class).to receive(:ifconfig).with(['vlan0', 'destroy'])
        vlan_interface.provider.destroy
      end

      it "should shutdown a real interface" do
        expect(provider_class).to receive(:ifconfig).with(['em0', 'down'])
        expect(provider_class).to_not receive(:ifconfig).with(['em0', 'destroy'])
        em_interface.provider.destroy
      end
    end
  end

  context "#create" do
    before do
      expect(provider_class).to receive(:ifconfig).with(['-C']) { 'vlan pflog0' }
    end

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

  context "#state" do
    platforms = ['FreeBSD', 'OpenBSD']
    states = ['up','down']
    if_type = 'em'

    platforms.each do |platform|
      context "on #{platform}" do
        states.each do |state|
          it "should detect interface state when #{state}" do
            p = platform.downcase
            info = File.read("spec/fixtures/ifconfig_#{p}.#{if_type}.#{state}")
            expect(provider_class).to receive(:ifconfig).with(["#{if_type}0"]) { info }
            expect(em_interface.provider.state).to eq(state)
          end
        end
      end
    end
  end
end
