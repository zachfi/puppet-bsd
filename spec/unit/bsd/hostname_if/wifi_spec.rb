require 'puppet_x/bsd/hostname_if/wifi'

describe 'Wifi' do
  subject(:wifiif) { Hostname_if::Wifi }

  describe 'content' do
    it 'should support a minimal example' do
      c = {
        :network_name => 'myssid',
      }
      expect(wifiif.new(c).content).to match(/nwid myssid/)
    end

    it 'should support a minimal example with dhcp' do
      c = {
        :network_name => 'myssid',
        :address      => ['dhcp'],
      }
      expect(wifiif.new(c).content).to match(/dhcp\nnwid myssid/)
    end

    it 'should support a partial example' do
      c = {
        :network_name => 'myssid',
        :wpa_key => 'mykey',
      }
      expect(wifiif.new(c).content).to match(/nwid myssid wpakey mykey/)
    end

    it 'should support a full example' do
      c = {
        :network_name => 'myssid',
        :wpa_key => 'mykey',
        :address => ['10.0.0.1/24'],
      }
      expect(wifiif.new(c).content).to match(/inet 10.0.0.1 255.255.255.0 NONE\nnwid myssid wpakey mykey/)
    end
  end
end

