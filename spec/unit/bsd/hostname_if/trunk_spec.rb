require 'puppet_x/bsd/hostname_if/trunk'

describe 'Trunk' do
  subject(:trunkif) { Hostname_if::Trunk }

  describe 'content' do
    it 'supports a full example' do
      c = {
        proto: 'lacp',
        interface: ['em0']
      }
      expect(trunkif.new(c).content).to match(%r{trunkproto lacp trunkport em0})
    end

    it 'supports a partial example' do
      c = {
        proto: 'lacp',
        interface: %w(
          em0
          em1
          em2
          em3
        )
      }
      expect(trunkif.new(c).content).to match(%r{trunkproto lacp trunkport em0 trunkport em1 trunkport em2 trunkport em3})
    end
  end
end
