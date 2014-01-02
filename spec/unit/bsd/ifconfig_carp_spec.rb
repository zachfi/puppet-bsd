require 'puppet_x/bsd/ifconfig_carp'

describe 'PuppetX::BSD::Ifconfig_carp' do

  describe 'validation' do
    it 'should fail if no config is supplied' do
      c = {}
      expect { PuppetX::BSD::Ifconfig_carp.new(c).content }.to raise_error
    end
  end

  describe 'content' do
    it 'should support a full example' do
      c = {
        :vhid    => '1',
        :address => '10.0.0.1/24',
        :advbase => '1',
        :advskew => '0',
        :carpdev => 'em0',
      }
      PuppetX::BSD::Ifconfig_carp.new(c).content.should match(/10.0.0.1\/24 vhid 1 advbase 1 advskew 0 carpdev em0/)
    end

    it 'should support a partial example' do
      c = {
        :vhid    => '1',
        :address => '10.0.0.1/24',
        :advbase => '1',
        :advskew => '0',
      }
      PuppetX::BSD::Ifconfig_carp.new(c).content.should match(/10.0.0.1\/24 vhid 1 advbase 1 advskew 0/)
    end
  end

end
