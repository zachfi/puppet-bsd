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
    platforms = ['OpenBSD','FreeBSD']

    platforms.each do |platform|
      context "on #{platform}" do
        states.each do |state|
          context "when interface state is #{state}" do
            if_types.each do |if_type|
              context "on a #{if_type} interface" do

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

                let!(:info) { File.read(ifconfig_fixture) }

                let!(:interface) { Puppet::Type.type(:bsd_interface).new(
                  :name => ifname,
                  :provider => 'ifconfig',
                  :ensure => state,
                ) }

                before do
                  expect(interface.provider).to receive(:pseudo_devices) { ['vlan', 'pflog'] }
                  expect(interface.provider).to receive(:get_state) { info }
                end

                case state
                when 'up', 'present'
                  it "should be present" do
                    expect(interface.provider.exists?).to eq(true)
                  end
                when 'absent'
                  it "should be absent" do
                    expect(interface.provider.exists?).to eq(false)
                  end
                when 'down'
                  case if_type
                  when 'real'
                    it "should be absent" do
                      expect(interface.provider.exists?).to eq(false)
                    end
                  when 'pseudo'
                    it "should be present" do
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

    case if_type
    when 'pseudo'
      ifname = 'vlan0'
    when 'real'
      ifname = 'em0'
    end

    platforms.each do |platform|
      context "on #{platform}" do
        states.each do |state|


          case state
          when 'up','down'
            it "should detect interface state when #{state}" do
              p = platform.downcase
              info = File.read("spec/fixtures/ifconfig_#{p}.#{if_type}.#{state}")

              expect(em_interface.provider).to receive(:get_state).and_return(info)
              expect(em_interface.provider.state).to eq(state)
            end
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

          context "when managing #{if_type} interface" do
            platforms.each do |platform|
              context "on #{platform}" do
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
                    it "should leave the interface state untouched" do
                      expect(em_interface.provider).to receive(:pseudo_devices) { ['vlan', 'pflog'] }
                      expect(em_interface.provider).to receive(:get_state) { info }
                      expect(provider_class).to_not receive(:ifconfig).with([ifname, 'create'])
                      expect(provider_class).to_not receive(:ifconfig).with([ifname, 'up'])
                      em_interface.provider.create
                    end
                  end
                when 'pseudo'
                  case state
                  when 'absent'
                    it "should create the interface" do
                      expect(vlan_interface.provider).to receive(:pseudo_devices) { ['vlan', 'pflog'] }
                      expect(vlan_interface.provider).to receive(:get_state) { info }
                      expect(provider_class).to receive(:ifconfig).with([ifname, 'create'])
                      expect(provider_class).to receive(:ifconfig).with([ifname, 'up'])
                      vlan_interface.provider.create
                    end
                  when 'up'
                    it "should leave the interface state untouched" do
                      expect(vlan_interface.provider).to receive(:pseudo_devices) { ['vlan', 'pflog'] }
                      expect(vlan_interface.provider).to receive(:get_state) { info }
                      expect(provider_class).to_not receive(:ifconfig).with([ifname, 'create'])
                      expect(provider_class).to_not receive(:ifconfig).with([ifname, 'up'])
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
