require 'spec_helper'
require 'puppet_x/bsd/util'

describe 'PuppetX::BSD::Util' do
  context '#uber_merge' do

    it 'should combind simple hashes' do
      h1 = {:one => 1}
      h2 = {:two => 2}

      wanted = {:one => 1, :two => 2}

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end

    it 'should combine nested hashses' do
      h1 = {:one => 1}
      h2 = {:two => 2}

      wanted = {:one => 1, :two => 2}

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end

    it 'should handle an empty initial hash' do
      h1 = {}
      h2 = {:one => 1}

      wanted = {:one => 1}

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end

    it 'should handle an initial hash with an array for value' do
      h1 = {:one => ['a', 'b']}
      h2 = {:two => {'eh' => 'a', 'bee' => 'b'}}

      wanted = {:one => ['a', 'b'],:two => {'eh' => 'a', 'bee' => 'b' }}

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end

    it 'Should combine values into an array' do
      h1 = {:root => {:sub => 1}}
      h2 = {:root => {:sub => 2}}

      wanted = {:root => {:sub => [1,2]}}

      expect(PuppetX::BSD::Util.uber_merge(h1, h2)).to eq(wanted)
    end

  end
end
