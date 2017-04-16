require 'puppet_x/bsd/rc_conf/carp'

describe 'PuppetX::BSD::Rc_conf::Carp' do
  describe 'validation' do
    context 'when the config is invalid' do
      it 'should fail if no config is supplied' do
        c = {}
        expect {
          PuppetX::BSD::Rc_conf::Carp.new(c).content
        }.to raise_error(ArgumentError)
      end

      it "should raise an error if device is missing" do
        c = {
          :id      => '1',
          :address => '10.0.0.1/24',
        }
        expect {
          PuppetX::BSD::Rc_conf::Carp.new(c).content
        }.to raise_error(ArgumentError, /device.*required/)
      end

      it "should raise an error if address is missing" do
        c = {
          :id     => '1',
          :device => 'em0',
        }
        expect {
          PuppetX::BSD::Rc_conf::Carp.new(c).content
        }.to raise_error
      end

      it "should not raise an error if address is present" do
        c = {
          :id      => '1',
          :device  => 'em0',
          :address => '10.0.0.1/24',
        }
        expect {
          PuppetX::BSD::Rc_conf::Carp.new(c).content
        }.not_to raise_error
      end

      it "should raise an error if missing arguments" do
        c = {
          :id      => '1',
          :device  => 'em0',
          :address => '10.0.0.0/24',
          :random  => '1',
        }
        expect {
          PuppetX::BSD::Rc_conf::Carp.new(c).content
        }.to raise_error(ArgumentError, /unknown configuration item/)
      end
    end
  end

  describe '#content' do
    context 'when only a device and a carp are supplied' do
      it 'should return the ifconfig string' do
        c = {
          :id      => '1',
          :address => '10.0.0.0/24',
          :device  => 'em0',
        }
        wanted = [
        'vhid 1',
        ]
        expect(PuppetX::BSD::Rc_conf::Carp.new(c).content).to match(wanted.join('\n'))
      end
    end
  end
end

