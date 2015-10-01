require 'puppet_x/bsd/hostname_if/vlan'

describe 'PuppetX::BSD::Hostname_if::Vlan' do
  describe 'validation' do
    it 'should fail if no config is supplied' do
      c = {}
      expect {
        PuppetX::BSD::Hostname_if::Vlan.new(c).content
      }.to raise_error(ArgumentError)
    end

    it "should raise an error if missing arguments" do
      c = {
        :id     => '1',
      }
      expect {
        PuppetX::BSD::Hostname_if::Vlan.new(c).content
      }.to raise_error(ArgumentError, /device.*required/)
    end

    it "should not raise an error if address is present" do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => '10.0.0.0/24',
      }
      expect {
        PuppetX::BSD::Hostname_if::Vlan.new(c).content
      }.not_to raise_error
    end

    it "should not raise an error if address is absent" do
      c = {
        :id      => '1',
        :device  => 'em0',
      }
      expect {
        PuppetX::BSD::Hostname_if::Vlan.new(c).content
      }.not_to raise_error
    end

    it "should raise an error if invalid vlan id given" do
      c = {
        :id     => '4095',
        :device => 'em0',
      }
      expect {
        PuppetX::BSD::Hostname_if::Vlan.new(c).content
      }.to raise_error(ArgumentError, /invalid vlan ID: 4095/)
    end

    it "should raise an error with invalid parameter" do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => '10.0.0.0/24',
        :random  => '1',
      }
      expect {
        PuppetX::BSD::Hostname_if::Vlan.new(c).content
      }.to raise_error(ArgumentError, /unknown configuration item/)
    end
  end

  describe 'content' do
    it 'should support a full example' do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => '10.0.0.1/24',
      }
      wanted = [
       'vlan 1 vlandev em0',
       'inet 10.0.0.1 255.255.255.0 NONE',
      ]
      expect(PuppetX::BSD::Hostname_if::Vlan.new(c).content).to match(wanted.join('\n'))
    end

    it 'should support a partial example' do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => '10.0.0.1/24',
      }

      wanted = [
       'vlan 1 vlandev em0',
       'inet 10.0.0.1 255.255.255.0 NONE',
      ]
      expect(PuppetX::BSD::Hostname_if::Vlan.new(c).content).to match(wanted.join('\n'))
    end

    it 'should support a allow an array of addresses' do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => [
          '10.0.0.1/24',
          '10.1.0.1/24',
          'fc00:1::/64',
          'fc00:2::/64',
        ]
      }
      wanted = [
       'vlan 1 vlandev em0',
       'inet 10.0.0.1 255.255.255.0 NONE',
       'inet alias 10.1.0.1 255.255.255.0 NONE',
       'inet6 fc00:1:: 64',
       'inet6 alias fc00:2:: 64'
      ]

      expect(PuppetX::BSD::Hostname_if::Vlan.new(c).content).to match(wanted.join('\n'))
    end
  end

  describe '#values' do
    it 'should return a list of values for a full example' do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => [
          '10.0.0.1/24',
          '10.1.0.1/24',
          'fc00:1::/64',
          'fc00:2::/64',
        ]
      }
      wanted = [
       'vlan 1 vlandev em0',
       'inet 10.0.0.1 255.255.255.0 NONE',
       'inet alias 10.1.0.1 255.255.255.0 NONE',
       'inet6 fc00:1:: 64',
       'inet6 alias fc00:2:: 64'
      ]

      expect(PuppetX::BSD::Hostname_if::Vlan.new(c).values).to match_array(wanted)
    end
  end
end
