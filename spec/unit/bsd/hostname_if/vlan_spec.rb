require 'puppet_x/bsd/hostname_if/vlan'

describe 'Vlan' do
  subject(:vlanif) { Hostname_if::Vlan }

  describe 'content' do
    it 'supports a full example' do
      c = {
        id: 1,
        device: 'em0',
        address: ['10.0.0.1/24']
      }
      wanted = [
        'vlan 1 vlandev em0',
        'inet 10.0.0.1 255.255.255.0 NONE'
      ]
      expect(vlanif.new(c).content).to match(wanted.join('\n'))
    end

    it 'supports a partial example' do
      c = {
        id: 1,
        device: 'em0',
        address: ['10.0.0.1/24']
      }

      wanted = [
        'vlan 1 vlandev em0',
        'inet 10.0.0.1 255.255.255.0 NONE'
      ]
      expect(vlanif.new(c).content).to match(wanted.join('\n'))
    end

    it 'supports a allow an array of addresses' do
      c = {
        id: 1,
        device: 'em0',
        address: [
          '10.0.0.1/24',
          '10.1.0.1/24',
          'fc00:1::/64',
          'fc00:2::/64'
        ]
      }
      wanted = [
        'vlan 1 vlandev em0',
        'inet 10.0.0.1 255.255.255.0 NONE',
        'inet alias 10.1.0.1 255.255.255.0 NONE',
        'inet6 fc00:1:: 64',
        'inet6 alias fc00:2:: 64'
      ]

      expect(vlanif.new(c).content).to match(wanted.join('\n'))
    end
  end

  describe '#values' do
    it 'returns a list of values for a full example' do
      c = {
        id: 1,
        device: 'em0',
        address: [
          '10.0.0.1/24',
          '10.1.0.1/24',
          'fc00:1::/64',
          'fc00:2::/64'
        ]
      }
      wanted = [
        'vlan 1 vlandev em0',
        'inet 10.0.0.1 255.255.255.0 NONE',
        'inet alias 10.1.0.1 255.255.255.0 NONE',
        'inet6 fc00:1:: 64',
        'inet6 alias fc00:2:: 64'
      ]

      expect(vlanif.new(c).values).to match_array(wanted)
    end
  end
end
