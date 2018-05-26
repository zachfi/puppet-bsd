require 'puppet_x/bsd/rc_conf/trunk'
require 'spec_helper'

describe 'Trunk' do
  subject(:trunk) { Trunk }

  describe '#content' do
    context 'when multiple interfaces and lacp' do
      it 'returns the desired output' do
        c = {
          proto: 'lacp',
          interface: %w[
            em0
            em1
          ]
        }
        wanted = [
          'laggproto lacp laggport em0 laggport em1'
        ]

        expect(trunk.new(c).content).to match(wanted.join('\n'))
      end
    end
  end
end
