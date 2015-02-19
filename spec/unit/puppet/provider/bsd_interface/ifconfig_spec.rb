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

  [:up, :down, :create, :destroy].each {|m| it { should respond_to(m) } }

  context "#exists?" do
    states = ['present','up','absent','down']
    if_types = ['pseudo', 'real']
    platforms = ['OpenBSD']

    states.each do |state|
      context "interface state is #{state}" do
        platforms.each do |platform|

          context "on #{platform}" do
            if_types.each do |if_type|
              context "on a #{if_type} interface" do

                case if_type
                when 'pseudo'
                  ifname = 'vlan0'
                when 'real'
                  ifname = 'em0'
                end

                before do
                  expect(provider_class).to receive(:ifconfig).with(['-C']) { 'vlan pflog0' }
                  expect(provider_class).to receive(:ifconfig).with([ifname]) { info }
                end

                p = platform.downcase

                case if_type
                when 'real'
                  ifname = 'em0'
                  case state
                  when 'present'
                    ifconfig_fixture = "spec/fixtures/ifconfig_#{p}.em.up"
                  else
                    ifconfig_fixture = "spec/fixtures/ifconfig_#{p}.em.#{state}"
                  end
                when 'pseudo'
                  ifname = 'vlan0'
                  case state
                  when 'present'
                    ifconfig_fixture = "spec/fixtures/ifconfig_#{p}.vlan.up"
                  else
                    ifconfig_fixture = "spec/fixtures/ifconfig_#{p}.vlan.#{state}"
                  end
                end

                let(:info) { File.read(ifconfig_fixture) }

                case state
                when 'up', 'present'
                  it "should be present" do
                    interface = Puppet::Type.type(:bsd_interface).new(
                      :name => ifname,
                      :provider => 'ifconfig',
                      :ensure => state,
                    )
                    expect(interface.provider.exists?).to eq(true)
                  end
                when 'absent'
                  it "should be absent" do
                    interface = Puppet::Type.type(:bsd_interface).new(
                      :name => ifname,
                      :provider => 'ifconfig',
                      :ensure => state,
                    )
                    expect(interface.provider.exists?).to eq(false)
                  end
                when 'down'
                  case if_type
                  when 'real'
                    it "should be absent" do
                      interface = Puppet::Type.type(:bsd_interface).new(
                        :name => ifname,
                        :provider => 'ifconfig',
                        :ensure => state,
                      )
                      expect(interface.provider.exists?).to eq(false)
                    end
                  when 'pseudo'
                    it "should be present" do
                      interface = Puppet::Type.type(:bsd_interface).new(
                        :name => ifname,
                        :provider => 'ifconfig',
                        :ensure => state,
                      )
                      expect(interface.provider.exists?).to eq(true)
                    end
                  end
                end

              end
            end

          end
        end
      end
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

  context "#create" do
    if_types = ['pseudo', 'real']
    states = ['absent','up']
    platforms = ['OpenBSD']

    states.each do |state|
      context "interface state is #{state}" do
        if_types.each do |if_type|

          case if_type
          when 'pseudo'
            ifname = 'vlan0'
          when 'real'
            ifname = 'em0'
          end

          context "when managing #{if_type} interface" do
            platforms.each do |platform|
              context "on #{platform}" do
                #p = platform.downcase
                #ifconfig_fixture = "spec/fixtures/ifconfig_#{p}.em.#{state}"
                #puts ifconfig_fixture
                #expect(provider_class).to receive(:ifconfig).with([ifname]).at_least(:once) { info }
                p = platform.downcase
                case if_type
                when 'real'
                  ifname = 'em0'
                  ifconfig_fixture = "spec/fixtures/ifconfig_#{p}.em.#{state}"
                when 'pseudo'
                  ifname = 'vlan0'
                  ifconfig_fixture = "spec/fixtures/ifconfig_#{p}.vlan.#{state}"
                end

                let(:info) { File.read(ifconfig_fixture) }

                case if_type
                when 'real'
                  case state
                  when 'up'
                    it "should set the interface up" do
                      expect(provider_class).to receive(:ifconfig).with(['-C']) { 'vlan pflog0' }
                      expect(provider_class).to_not receive(:ifconfig).with([ifname, 'create'])
                      expect(provider_class).to receive(:ifconfig).with([ifname, 'up'])
                      em_interface.provider.create
                    end
                  end
                when 'pseudo'
                  case state
                  when 'absent'
                    it "should create the interface" do
                      expect(provider_class).to receive(:ifconfig).with(['-C']) { 'vlan pflog0' }
                      expect(provider_class).to receive(:ifconfig).with([ifname]) { info }
                      expect(provider_class).to receive(:ifconfig).with([ifname, 'create'])
                      expect(provider_class).to receive(:ifconfig).with([ifname, 'up'])
                      vlan_interface.provider.create
                    end
                  when 'up'
                    it "should set the interface up" do
                      expect(provider_class).to receive(:ifconfig).with(['-C']) { 'vlan pflog0' }
                      expect(provider_class).to receive(:ifconfig).with([ifname]) { info }
                      expect(provider_class).to_not receive(:ifconfig).with([ifname, 'create'])
                      expect(provider_class).to receive(:ifconfig).with([ifname, 'up'])
                      vlan_interface.provider.create
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
