require 'spec_helper'
require 'puppet/provider/bsd_interface/ifconfig'

describe Puppet::Type.type(:bsd_interface).provider(:ifconfig) do
  let(:ifconfig) { 'ifconfig' }

  let(:em_interface) do
    Puppet::Type.type(:bsd_interface).new(
      name: 'em0',
      provider: em_provider
    )
  end
  let(:em_provider) { described_class.new(name: 'em0') }

  let(:vlan_interface) do
    Puppet::Type.type(:bsd_interface).new(
      name: 'vlan0',
      provider: vlan_provider
    )
  end
  let(:vlan_provider) { described_class.new(name: 'vlan0') }

  context '#instances' do
    let(:output) { File.read('spec/fixtures/ifconfig_openbsd.full') }

    before do
      expect(described_class).to receive(:execute).with(['/sbin/ifconfig', '-C'], failonfail: false, combine: true) { 'vlan pflog' }
      expect(described_class).to receive(:execute).with(['/sbin/ifconfig'], failonfail: false, combine: true) { output }
    end

    it 'returns some instances' do
      expect(described_class.instances.size).to eq(15)
    end

    it 'returns an array of interfaces' do
      expect(described_class.instances.class).to be(Array)
    end

    it 'returns the resource dc=bar,dc=com' do
      expect(described_class.instances[1].instance_variable_get('@property_hash')).to eq(
        ensure: :present, provider: :bsd_interface, name: 'em0', flags: %w(UP BROADCAST RUNNING SIMPLEX MULTICAST), mtu: 1500, destroyable: :false, state: :up
      )
    end

    it 'returns all interfaces names' do
      expect(described_class.instances.map(&:name).sort).to eq(%w(bridge0 bridge1 em0 em1 em2 em3 em4 em5 em6 em7 lo0 pflog0 vether0 vether1 vlan88))
    end
  end

  [:up, :down, :create, :destroy].each { |m| it { is_expected.to respond_to(m) } }

  context '#flush' do
    states = %w(up absent down)
    ensure_states = %w(present up absent down)
    if_types = %w(pseudo real)
    platforms = %w(OpenBSD FreeBSD)
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
                when 'present', 'down', 'up'
                  it 'returns a single instance' do
                    expect(described_class).to receive(:execute).with(['/sbin/ifconfig', '-C'], failonfail: false, combine: true) { 'vlan pflog' }
                    expect(described_class).to receive(:execute).with(['/sbin/ifconfig'], failonfail: false, combine: true) { info }
                    expect(described_class.instances.size).to eq(1)
                  end
                when 'absent'
                  it 'returns zero instances' do
                    expect(described_class).to receive(:execute).with(['/sbin/ifconfig', '-C'], failonfail: false, combine: true) { 'vlan pflog' }
                    expect(described_class).to receive(:execute).with(['/sbin/ifconfig'], failonfail: false, combine: true) { info }
                    expect(described_class.instances.size).to eq(0)
                  end
                end

                ensure_states.each do |ensure_state|
                  context "when ensure is #{ensure_state}" do
                    let!(:provider) do
                      described_class.new(
                        name: ifname,
                        ensure: ensure_state
                      )
                    end

                    let!(:interface) do
                      Puppet::Type.type(:bsd_interface).new(
                        name: ifname,
                        provider: provider,
                        ensure: state
                      )
                    end

                    # We only call instances on these states, which we expect to call ifconfig twice.
                    if %w(present up down).include? state
                      before do
                        expect(described_class).to receive(:execute).with(['/sbin/ifconfig', '-C'], failonfail: false, combine: true) { 'vlan pflog' }
                        expect(described_class).to receive(:execute).with(['/sbin/ifconfig'], failonfail: false, combine: true) { info }
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
                            expect(i).not_to receive(:execute).with(['/sbin/ifconfig', ifname, 'create'], failonfail: false, combine: true)
                          end
                          expect(i).not_to receive(:execute).with(['/sbin/ifconfig', ifname, 'up'], failonfail: false, combine: true)
                          i.up
                          i.flush
                        end
                      when 'present'
                        it 'leave the interface untouched' do
                          i = described_class.instances[0]
                          if if_type == 'pseudo'
                            expect(i).not_to receive(:execute).with(['/sbin/ifconfig', ifname, 'create'], failonfail: false, combine: true)
                          end
                          expect(i).not_to receive(:execute).with(['/sbin/ifconfig', ifname, 'up'], failonfail: false, combine: true)
                          i.flush
                        end
                      when 'down'
                        it 'brings the interface down' do
                          i = described_class.instances[0]
                          if if_type == 'pseudo'
                            expect(i).not_to receive(:execute).with(['/sbin/ifconfig', ifname, 'create'], failonfail: false, combine: true)
                            expect(i).not_to receive(:execute).with(['/sbin/ifconfig', ifname, 'destroy'], failonfail: false, combine: true)
                          end
                          expect(i).to receive(:execute).with(['/sbin/ifconfig', ifname, 'down'], failonfail: false, combine: true)
                          i.down
                          i.flush
                        end
                      when 'absent'
                        it 'brings down and destroy the interface when necessary' do
                          i = described_class.instances[0]
                          expect(i).to receive(:execute).with(['/sbin/ifconfig', ifname, 'down'], failonfail: false, combine: true)
                          if if_type == 'pseudo'
                            expect(i).not_to receive(:execute).with(['/sbin/ifconfig', ifname, 'create'], failonfail: false, combine: true)
                            expect(i).to receive(:execute).with(['/sbin/ifconfig', ifname, 'destroy'], failonfail: false, combine: true)
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
                        it 'brings up the interface' do
                          i = described_class.instances[0]
                          i.up
                          expect(i).to receive(:execute).with(['/sbin/ifconfig', ifname, 'up'], failonfail: false, combine: true)
                          i.flush
                        end
                      when 'present'
                      when 'down'
                      when 'absent'
                      end
                    when 'absent'
                      it 'is absent' do
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
