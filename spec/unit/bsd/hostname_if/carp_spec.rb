require 'puppet_x/bsd/hostname_if/carp'

describe 'Carp' do
  subject(:carpif) { Hostname_if::Carp }

  describe 'initialize' do
    context 'when minimal configuration is passed' do
      it 'should not error' do
        expect {
          subject.new({
            :id      => '1',
            :device  => 'em0',
            :address => ['10.0.0.1/24'],
          })
        }.to_not raise_error
      end
    end
  end

  describe 'content' do
    it 'should support a full example' do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => ['10.0.0.1/24'],
        :advbase => '1',
        :advskew => '0',
        :pass    => 'TopSecret',
      }
      expect(subject.new(c).content).to match(/vhid 1 pass TopSecret carpdev em0 advbase 1 advskew 0\ninet 10.0.0.1 255.255.255.0 NONE/)
    end

    it 'should support a partial example' do
      c = {
        :id      => '1',
        :device  => 'em0',
        :address => ['10.0.0.1/24'],
        :advbase => '1',
        :advskew => '0',
      }
      expect(subject.new(c).content).to match(/vhid 1 carpdev em0 advbase 1 advskew 0\ninet 10.0.0.1 255.255.255.0 NONE/)
    end
  end
end
