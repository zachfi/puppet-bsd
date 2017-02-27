require 'puppet_x/bsd/hostname_if/wifi'

describe 'Wifi' do
  subject(:wifiif) { Hostname_if::Wifi }

  describe 'content' do
    it 'supports a minimal example' do
      c = {
        network_name: 'myssid'
      }
      expect(wifiif.new(c).content).to match(%r{nwid myssid})
    end

    it 'supports a minimal example with dhcp' do
      c = {
        network_name: 'myssid',
        address: ['dhcp']
      }
      expect(wifiif.new(c).content).to match(%r{dhcp\nnwid myssid})
    end

    it 'supports a partial example' do
      c = {
        network_name: 'myssid',
        wpa_key: 'mykey'
      }
      expect(wifiif.new(c).content).to match(%r{nwid myssid wpakey mykey})
    end

    it 'supports a full example' do
      c = {
        network_name: 'myssid',
        wpa_key: 'mykey',
        address: ['10.0.0.1/24']
      }
      expect(wifiif.new(c).content).to match(%r{inet 10.0.0.1 255.255.255.0 NONE\nnwid myssid wpakey mykey})
    end
  end
end
