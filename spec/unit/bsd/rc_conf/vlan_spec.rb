require 'puppet_x/bsd/rc_conf/vlan'


describe 'Vlan' do
  subject(:vlan) { Vlan }

  describe 'validation' do
    context 'when the config is invalid' do
      it 'should fail if no config is supplied' do
        c = {}
        expect {
          vlan.new(c).content
        }.to raise_error(ArgumentError)
      end

      it "should raise an error if device is missing" do
        c = {
          :id     => '1',
        }
        expect {
          vlan.new(c).content
        }.to raise_error(ArgumentError, /required configuration item not found: device/)
      end

      it "should not raise an error if address is missing" do
        c = {
          :id     => '1',
          :device => 'em0',
        }
        expect {
          vlan.new(c).content
        }.not_to raise_error
      end

      it "should not raise an error if address is an empty array" do
        c = {
          :id      => '1',
          :device  => 'em0',
          :address => [],
        }
        expect {
          vlan.new(c).content
        }.not_to raise_error
      end

      it "should not raise an error if address is present" do
        c = {
          :id      => '1',
          :device  => 'em0',
          :address => ['10.0.0.0/24'],
        }
        expect {
          vlan.new(c).content
        }.not_to raise_error
      end

      it "should raise an error when an invalid option is received" do
        c = {
          :id      => '1',
          :device  => 'em0',
          :address => ['10.0.0.0/24'],
          :random  => '1',
        }
        expect {
          vlan.new(c).content
        }.to raise_error(ArgumentError, /unknown configuration item/)
      end
    end
  end

  describe '#content' do
    context 'when only a device and a vlan are supplied' do
      it 'should return the ifconfig string' do
        c = {
          :id      => '1',
          :device  => 'em0',
        }
        wanted = [
        'vlan 1 vlandev em0',
        ]
        expect(vlan.new(c).content).to match(wanted.join('\n'))
      end
    end

    context 'when a single address is passed' do
      it 'should return only the vlan string' do
        c = {
          :id      => '1',
          :device  => 'em0',
          :address => ['10.0.0.1/24'],
        }
        wanted = [
          'vlan 1 vlandev em0',
        ]
        expect(vlan.new(c).content).to match(wanted.join('\n'))
      end
    end
  end
end
