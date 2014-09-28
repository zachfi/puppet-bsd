require 'puppet_x/bsd/rc_conf'

describe 'PuppetX::BSD::Rc_conf' do
  subject(:rc) { PuppetX::BSD::Rc_conf }

  describe '#validate_config' do
    context "when config is not present" do
      it "should raise an error" do
        expect { rc.new() }.to raise_error
      end
    end

    context "when minimal config is supplied" do
      it "should not raise an error" do
        c = {
          :name   => 're0',
          :desc   => "Uplink",
        }
        expect { rc.new(c) }.to_not raise_error
      end
    end
  end

  describe '#get_hash' do
    context 'when a full config is supplied' do
      it 'should return the desired hash' do

        hash = {
          :re0 => {
            :addrs => [
              "inet 10.0.1.12/24 mtu 9000",
              "inet6 fc00::123/64",
            ],
            :aliases => [
              "inet 10.0.1.13/24",
              "inet 10.0.1.14/24",
              "inet6 fc00::124/64",
              "inet6 fc00::125/64",
            ],
          }
        }

        c = {
          :name   => 're0',
          :desc   => "Uplink",
          :address => [
            '10.0.1.12/24',
            '10.0.1.13/24',
            '10.0.1.14/24',
            'fc00::123/64',
            'fc00::124/64',
            'fc00::125/64',
          ],
          :options => [
            'mtu 9000',
          ]
        }
        expect(rc.new(c).get_hash).to eq(hash)
      end
    end
  end

  describe '#to_create_resources' do
    context 'when a full interface config is supplied' do
      it 'should convert the hash for create_resources()' do
        hash = {
          'ifconfig_re0' => {
            'key'   => 'ifconfig_re0',
            'value' => 'inet 10.0.1.12/24 mtu 9000',
          },
          'ifconfig_re0_alias0' => {
            'key'   => 'ifconfig_re0_alias0',
            'value' => 'inet 10.0.1.13/24',
          },
          'ifconfig_re0_alias1' => {
            'key'   => 'ifconfig_re0_alias1',
            'value' => 'inet 10.0.1.14/24',
          },
          'ifconfig_re0_ipv6' => {
            'key'   => 'ifconfig_re0_ipv6',
            'value' => 'inet6 fc00::123/64',
          },
          'ifconfig_re0_alias2' => {
            'key'   => 'ifconfig_re0_alias2',
            'value' => 'inet6 fc00::124/64',
          },
        }

        c = {
          :name   => 're0',
          :desc   => "Uplink",
          :address => [
            '10.0.1.12/24',
            '10.0.1.13/24',
            '10.0.1.14/24',
            'fc00::123/64',
            'fc00::124/64',
          ],
          :options => [
            'mtu 9000',
          ]
        }
        expect(rc.new(c).to_create_resources).to eq(hash)
      end
    end

    context 'when only a vlan configuration is supplied' do
      it 'should convert the hash for create_resources()' do
        hash = {
          'ifconfig_vlan100' => {
            'key'   => 'ifconfig_vlan100',
            'value' => 'vlan 100 vlandev re0',
          }
        }

        c = {
          :name   => 'vlan100',
          :desc   => "Uplink",
          :options => [
            'vlan 100',
            'vlandev re0',
          ]
        }
        expect(rc.new(c).to_create_resources).to eq(hash)
      end
    end
  end

  describe "#options_string" do
    context "when options are supplied" do
      it "should return the formatted string of options" do
        wanted = 'vlan 100 vlandev re0'
        c = {
          :name   => 'vlan100',
          :options => [
            'vlan 100',
            'vlandev re0',
          ]
        }
        expect(rc.new(c).options_string).to eq(wanted)
      end
    end
  end
end
