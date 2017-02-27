require 'puppet_x/bsd/hostname_if/pfsync'

describe 'Pfsync' do
  subject(:pfif) { Hostname_if::Pfsync }

  describe 'content' do
    it 'supports a minimal example' do
      c = {}
      expect(pfif.new(c).content).to match(%r{-syncdev -syncpeer maxupd 128 -defer})
    end

    it 'supports a partial example' do
      c = {
        syncdev: 'em0',
        syncpeer: '10.0.0.222'
      }
      expect(pfif.new(c).content).to match(%r{syncdev em0 syncpeer 10.0.0.222 maxupd 128 -defer})
    end
  end
end
