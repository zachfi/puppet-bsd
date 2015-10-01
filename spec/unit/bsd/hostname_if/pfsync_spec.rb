require 'puppet_x/bsd/hostname_if/pfsync'

describe 'PuppetX::BSD::Hostname_if::Pfsync' do
  describe 'validation' do
    it "should raise an error if wrong argument" do
      c = {
        :proto     => 'lacp',
      }
      expect {
        PuppetX::BSD::Hostname_if::Pfsync.new(c).content
      }.to raise_error(ArgumentError, /unknown configuration item/)
    end
    it "should raise an error if maxupd value is out of range" do
      c = {
        :maxupd     => '256',
      }
      expect {
        PuppetX::BSD::Hostname_if::Pfsync.new(c).content
      }.to raise_error(ArgumentError, /value of maxupd has to be in the range of 0 and 255/)
    end
  end

  describe 'content' do
    it 'should support a minimal example' do
      c = { }
      expect(PuppetX::BSD::Hostname_if::Pfsync.new(c).content).to match(/-syncdev -syncpeer maxupd 128 -defer/)
    end

    it 'should support a partial example' do
      c = {
        :syncdev  => 'em0',
        :syncpeer => '10.0.0.222',
      }
      expect(PuppetX::BSD::Hostname_if::Pfsync.new(c).content).to match(/syncdev em0 syncpeer 10.0.0.222 maxupd 128 -defer/)
    end
  end
end
