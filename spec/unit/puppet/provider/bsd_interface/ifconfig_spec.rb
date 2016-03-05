require 'spec_helper'
require 'puppet/provider/bsd_interface/ifconfig'

describe Puppet::Type.type(:bsd_interface).provider(:ifconfig) do
  let(:ifconfig) { 'ifconfig' }

  let(:em_interface) do
    Puppet::Type.type(:bsd_interface).new(
      :name => 'em0',
      :provider => em_provider)
  end
  let(:em_provider) { described_class.new(:name => 'em0') }

  let(:vlan_interface) do
    Puppet::Type.type(:bsd_interface).new(
      :name => 'vlan0',
      :provider => vlan_provider)
  end
  let(:vlan_provider) { described_class.new(:name => 'vlan0') }

  context "#instances" do
    let(:output) { File.read("spec/fixtures/ifconfig_openbsd.full") }

    before do
      expect(described_class).to receive(:execute).with(['/sbin/ifconfig', '-C'], {:failonfail=>false, :combine=>true}) { 'vlan pflog' }
      expect(described_class).to receive(:execute).with(['/sbin/ifconfig'], {:failonfail=>false, :combine=>true}) { output }
    end

    it 'should return some instances' do
      expect(described_class.instances.size).to eq(15)
    end

    it "should return an array of interfaces" do
      expect(described_class.instances.class).to be(Array)
    end

    it 'should return the resource dc=bar,dc=com' do
      expect(described_class.instances[1].instance_variable_get("@property_hash")).to eq(
        {:ensure => :present, :provider=>:bsd_interface, :name=>"em0", :flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :mtu=>1500, :destroyable=>:false, :state => :up}
      )
    end

    it "should return all interfaces names" do
      expect(described_class.instances.map(&:name).sort).to eq(["bridge0", "bridge1", "em0", "em1", "em2", "em3", "em4", "em5", "em6", "em7", "lo0", "pflog0", "vether0", "vether1", "vlan88"])
    end
  end

  [:up, :down, :create, :destroy].each {|m| it { should respond_to(m) } }

  context "#flush" do
    states = ['up','absent','down']
    ensure_states = ['present','up','absent','down']
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
                  ifconfig_fixture = "spec/fixtures/ifconfig_#{p}.em.#{state}"
                when 'pseudo'
                  ifname = 'vlan0'
                  ifconfig_fixture = "spec/fixtures/ifconfig_#{p}.vlan.#{state}"
                end

                let(:info) { File.read(ifconfig_fixture) }

                case state
                when 'present','down','up'
                  it 'should return a single instance' do
                    expect(described_class).to receive(:execute).with(['/sbin/ifconfig', '-C'], {:failonfail=>false, :combine=>true}) { 'vlan pflog' }
                    expect(described_class).to receive(:execute).with(['/sbin/ifconfig'], {:failonfail=>false, :combine=>true}) { info }
                    expect(described_class.instances.size).to eq(1)
                  end
                when 'absent'
                  it 'should return zero instances' do
                    expect(described_class).to receive(:execute).with(['/sbin/ifconfig', '-C'], {:failonfail=>false, :combine=>true}) { 'vlan pflog' }
                    expect(described_class).to receive(:execute).with(['/sbin/ifconfig'], {:failonfail=>false, :combine=>true}) { info }
                    expect(described_class.instances.size).to eq(0)
                  end
                end

                ensure_states.each do |ensure_state|
                  context "when ensure is #{ensure_state}" do
                    let!(:provider) { described_class.new(
                      :name => ifname,
                      :ensure => ensure_state
                    ) }

                    let!(:interface) { Puppet::Type.type(:bsd_interface).new(
                      :name => ifname,
                      :provider => provider,
                      :ensure => state,
                    ) }

                    # We only call instances on these states, which we expect to call ifconfig twice.
                    if ['present', 'up', 'down'].include? state
                      before do
                        expect(described_class).to receive(:execute).with(['/sbin/ifconfig', '-C'], {:failonfail=>false, :combine=>true}) { 'vlan pflog' }
                        expect(described_class).to receive(:execute).with(['/sbin/ifconfig'], {:failonfail=>false, :combine=>true}) { info }
                      end
                    end

                    case state
                    when 'up'
                      it 'instances should detect up' do
                        expect(described_class.instances[0].state).to eq(:up)
                      end

                      case ensure_state
                      when 'up'
                        it 'leave the interface untouched' do
                          i = described_class.instances[0]
                          if if_type == 'pseudo'
                            expect(i).to_not receive(:execute).with(['/sbin/ifconfig', ifname, 'create'], {:failonfail=>false, :combine=>true})
                          end
                          expect(i).to_not receive(:execute).with(['/sbin/ifconfig', ifname, 'up'], {:failonfail=>false, :combine=>true})
                          i.up
                          i.flush
                        end
                      when 'present'
                        it 'leave the interface untouched' do
                          i = described_class.instances[0]
                          if if_type == 'pseudo'
                            expect(i).to_not receive(:execute).with(['/sbin/ifconfig', ifname, 'create'], {:failonfail=>false, :combine=>true})
                          end
                          expect(i).to_not receive(:execute).with(['/sbin/ifconfig', ifname, 'up'], {:failonfail=>false, :combine=>true})
                          i.flush
                        end
                      when 'down'
                        it 'should bring the interface down' do
                          i = described_class.instances[0]
                          if if_type == 'pseudo'
                            expect(i).to_not receive(:execute).with(['/sbin/ifconfig', ifname, 'create'], {:failonfail=>false, :combine=>true})
                            expect(i).to_not receive(:execute).with(['/sbin/ifconfig', ifname, 'destroy'], {:failonfail=>false, :combine=>true})
                          end
                          expect(i).to receive(:execute).with(['/sbin/ifconfig', ifname, 'down'], {:failonfail=>false, :combine=>true})
                          i.down
                          i.flush
                        end
                      when 'absent'
                        it 'should bring down and destroy the interface when necessary' do
                          i = described_class.instances[0]
                          expect(i).to receive(:execute).with(['/sbin/ifconfig', ifname, 'down'], {:failonfail=>false, :combine=>true})
                          if if_type == 'pseudo'
                            expect(i).to_not receive(:execute).with(['/sbin/ifconfig', ifname, 'create'], {:failonfail=>false, :combine=>true})
                            expect(i).to receive(:execute).with(['/sbin/ifconfig', ifname, 'destroy'], {:failonfail=>false, :combine=>true})
                          end
                          i.destroy
                          i.flush
                        end
                      end

                    when 'down'
                      it 'instances should detect down' do
                        expect(described_class.instances[0].state).to eq(:down)
                      end

                      case ensure_state
                      when 'up'
                        it 'should bring up the interface' do
                          i = described_class.instances[0]
                          i.up
                          expect(i).to receive(:execute).with(['/sbin/ifconfig', ifname, 'up'], {:failonfail=>false, :combine=>true})
                          i.flush
                        end
                      when 'present'
                      when 'down'
                      when 'absent'
                      end
                    when 'absent'
                      it 'should be absent' do
                        expect(provider.state).to eq(:absent)
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

end
