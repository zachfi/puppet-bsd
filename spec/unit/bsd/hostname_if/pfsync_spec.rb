require 'puppet_x/bsd/hostname_if/pfsync'

describe 'Pfsync' do
  subject(:pfif) { Hostname_if::Pfsync }

  describe 'content' do
    it 'should support a minimal example' do
      c = { }
      expect(pfif.new(c).content).to match(/-syncdev -syncpeer maxupd 128 -defer/)
    end

    it 'should support a partial example' do
      c = {
        :syncdev  => 'em0',
        :syncpeer => '10.0.0.222',
      }
      expect(pfif.new(c).content).to match(/syncdev em0 syncpeer 10.0.0.222 maxupd 128 -defer/)
    end
  end
end
