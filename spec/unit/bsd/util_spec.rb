require 'spec_helper'
require 'puppet_x/bsd/util'

describe 'PuppetX::BSD::Util' do
  context '#uber_merge' do
    it 'combinds simple hashes' do
      h1 = { one: 1 }
      h2 = { two: 2 }

      wanted = { one: 1, two: 2 }

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end

    it 'combines nested hashses' do
      h1 = { one: 1 }
      h2 = { two: 2 }

      wanted = { one: 1, two: 2 }

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end

    it 'handles an empty initial hash' do
      h1 = {}
      h2 = { one: 1 }

      wanted = { one: 1 }

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end

    it 'handles an initial hash with an array for value' do
      h1 = { one: %w[a b] }
      h2 = { two: { 'eh' => 'a', 'bee' => 'b' } }

      wanted = { one: %w[a b], two: { 'eh' => 'a', 'bee' => 'b' } }

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end

    it 'combines values into an array' do
      h1 = { root: { sub: 1 } }
      h2 = { root: { sub: 2 } }

      wanted = { root: { sub: [1, 2] } }

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end
  end
end
