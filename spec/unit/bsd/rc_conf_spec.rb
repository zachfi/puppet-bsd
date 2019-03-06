require 'puppet_x/bsd/rc_conf'

describe 'Rc_conf' do
  subject(:rc) { Rc_conf }

  describe 'initialize' do
    context 'when minimal configuration is passed' do
      it 'does not error' do
        expect { rc.new(name: 'em0') }.not_to raise_error
      end
    end
  end

  describe '#get_hash' do
    context 'with a dynamic v4-only config' do
      it 'returns a valid config' do
        hash = {
          re0: {
            addrs: [
              'DHCP'
            ]
          }
        }

        c = {
          name: 're0',
          addresses: [
            'dhcp'
          ]
        }
        expect(rc.new(c).get_hash).to eq(hash)
      end

      context 'when an empty address set is passed' do
        it 'returns useless hash' do
          hash = {
            re0: {}
          }
          c = {
            name: 're0',
            addresses: []
          }

          expect(rc.new(c).get_hash).to eq(hash)
        end
      end

      context 'when a single address is passed' do
        it 'returns a correctly formatted hash' do
          hash = {
            re0: { addrs: ['inet 10.0.0.1/24'] }
          }
          c = {
            name: 're0',
            addresses: [
              '10.0.0.1/24'
            ]
          }

          expect(rc.new(c).get_hash).to eq(hash)
        end
      end
      context 'when multiple addresses are passed' do
        it 'returns a correctly formatted hash' do
          hash = {
            re0: {
              addrs: ['inet 10.0.0.1/24'],
              aliases: [
                'inet 10.0.0.2/24',
                'inet 10.0.0.3/24'
              ]
            }
          }
          c = {
            name: 're0',
            addresses: [
              '10.0.0.1/24',
              '10.0.0.2/24',
              '10.0.0.3/24'
            ]
          }

          expect(rc.new(c).get_hash).to eq(hash)
        end
      end
    end

    context 'when a full config is supplied' do
      it 'returns the desired hash' do
        hash = {
          re0: {
            addrs: [
              'inet 10.0.1.12/24 mtu 9000',
              'inet6 fc00::123/64'
            ],
            aliases: [
              'inet 10.0.1.13/24',
              'inet 10.0.1.14/24',
              'inet6 fc00::124/64',
              'inet6 fc00::125/64'
            ]
          }
        }

        c = {
          name: 're0',
          desc: 'Uplink',
          addresses: [
            '10.0.1.12/24',
            '10.0.1.13/24',
            '10.0.1.14/24',
            'fc00::123/64',
            'fc00::124/64',
            'fc00::125/64'
          ],
          mtu: 9000
        }
        expect(rc.new(c).get_hash).to eq(hash)
      end
    end
  end

  describe '#to_create_resources' do
    context 'when only mtu is spplied' do
      it do
        hash = {
          'ifconfig_re0' => {
            'value' => 'mtu 9000'
          }
        }

        c = {
          name: 're0',
          mtu: 9000
        }
        expect(rc.new(c).to_create_resources).to eq(hash)
      end
    end

    context 'when a full interface config is supplied' do
      it 'converts the hash for create_resources()' do
        hash = {
          'ifconfig_re0' => {
            'value' => 'inet 10.0.1.12/24 mtu 9000'
          },
          'ifconfig_re0_alias0' => {
            'value' => 'inet 10.0.1.13/24'
          },
          'ifconfig_re0_alias1' => {
            'value' => 'inet 10.0.1.14/24'
          },
          'ifconfig_re0_ipv6' => {
            'value' => 'inet6 fc00::123/64'
          },
          'ifconfig_re0_alias2' => {
            'value' => 'inet6 fc00::124/64'
          }
        }

        c = {
          name: 're0',
          desc: 'Uplink',
          addresses: [
            '10.0.1.12/24',
            '10.0.1.13/24',
            '10.0.1.14/24',
            'fc00::123/64',
            'fc00::124/64'
          ],
          options: [
            'mtu 9000'
          ]
        }
        expect(rc.new(c).to_create_resources).to eq(hash)
      end
    end

    context 'when only a vlan configuration is supplied' do
      it 'converts the hash for create_resources()' do
        hash = {
          'ifconfig_vlan100' => {
            'value' => 'vlan 100 vlandev re0'
          }
        }

        c = {
          name: 'vlan100',
          desc: 'Uplink',
          options: [
            'vlan 100',
            'vlandev re0'
          ]
        }
        expect(rc.new(c).to_create_resources).to eq(hash)
      end
    end

    context 'when raw_values are supplied' do
      it 'the raw_values appear in the hash for create_resources()' do
        hash = {
          'ifconfig_gre2' => {
            'value' => '192.168.1.1 netmask 255.255.255.252 tunnel 192.168.2.1 up'
          }
        }

        c = {
          name: 'gre2',
          desc: 'Uplink',
          raw_values: [
            '192.168.1.1 netmask 255.255.255.252 tunnel 192.168.2.1 up'
          ]
        }
        expect(rc.new(c).to_create_resources).to eq(hash)
      end
    end
  end

  describe '#options_string' do
    context 'when options are supplied' do
      it 'returns the formatted string of options' do
        wanted = 'vlan 100 vlandev re0'
        c = {
          name: 'vlan100',
          options: [
            'vlan 100',
            'vlandev re0'
          ]
        }
        expect(rc.new(c).options_string).to eq(wanted)
      end
    end
  end
end
