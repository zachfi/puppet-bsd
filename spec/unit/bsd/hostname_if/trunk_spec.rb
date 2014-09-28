require 'puppet_x/bsd/hostname_if/trunk'

describe 'PuppetX::BSD::Hostname_if::Trunk' do
  describe 'validation' do
    it 'should fail if no config is supplied' do
      c = {}
      expect {
        PuppetX::BSD::Hostname_if::Trunk.new(c).content
      }.to raise_error(ArgumentError)
    end

    it "should raise an error if missing arguments" do
      c = {
        :proto     => 'lacp',
      }
      expect {
        PuppetX::BSD::Hostname_if::Trunk.new(c).content
      }.to raise_error(ArgumentError, /interface.*required/)
    end

    it "should raise an error if missing arguments" do
      c = {
        :proto     => 'lacp',
        :interface => 'em0',
        :address   => '10.0.0.0/24',
        :random    => '1',
      }
      expect {
        PuppetX::BSD::Hostname_if::Trunk.new(c).content
      }.to raise_error(ArgumentError, /unknown configuration item/)
    end
  end

  describe 'content' do
    it 'should support a full example' do
      c = {
        :proto     => 'lacp',
        :interface => 'em0',
      }
      expect(PuppetX::BSD::Hostname_if::Trunk.new(c).content).to match(/trunkproto lacp trunkport em0/)
    end

    it 'should support a partial example' do
      c = {
        :proto     => 'lacp',
        :interface => [
          'em0',
          'em1',
          'em2',
          'em3',
        ]
      }
      expect(PuppetX::BSD::Hostname_if::Trunk.new(c).content).to match(/trunkproto lacp trunkport em0 trunkport em1 trunkport em2 trunkport em3/)
    end
  end
end
