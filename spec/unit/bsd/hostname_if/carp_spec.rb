require 'puppet_x/bsd/hostname_if/carp'

describe 'PuppetX::BSD::Hostname_if::Carp' do
  describe 'validation' do
    it 'should fail if no config is supplied' do
      c = {}
      expect { PuppetX::BSD::Hostname_if::Carp.new(c).content }.to raise_error
    end

    it "should raise an error if missing arguments" do
      c = {
        :id     => '1',
        :device => 'em0',
      }
      expect {
        PuppetX::BSD::Hostname_if::Carp.new(c).content
      }.to raise_error(ArgumentError, /address.*required/)
    end

    it "should raise an error if missing arguments" do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => '10.0.0.0/24',
        :random  => '1',
      }
      expect {
        PuppetX::BSD::Hostname_if::Carp.new(c).content
      }.to raise_error(ArgumentError, /unknown configuration item/)
    end
  end

  describe 'content' do
    it 'should support a full example' do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => '10.0.0.1/24',
        :advbase => '1',
        :advskew => '0',
      }
      PuppetX::BSD::Hostname_if::Carp.new(c).content.should match(/inet 10.0.0.1 255.255.255.0 NONE vhid 1 carpdev em0 advbase 1 advskew 0/)
    end

    it 'should support a partial example' do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => '10.0.0.1/24',
        :advbase => '1',
        :advskew => '0',
      }
      PuppetX::BSD::Hostname_if::Carp.new(c).content.should match(/inet 10.0.0.1 255.255.255.0 NONE vhid 1 carpdev em0 advbase 1 advskew 0/)
    end
  end
end
