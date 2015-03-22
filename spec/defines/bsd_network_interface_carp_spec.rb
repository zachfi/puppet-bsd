require 'spec_helper'

describe "bsd::network::interface::carp" do
  context "on OpenBSD" do
    let(:facts) { {:kernel => 'OpenBSD'} }
    let(:title) { 'carp0' }
    context " a minimal example" do
      let(:params) {
        {
          :id      => '1',
          :device  => 'em0',
          :address => '10.0.0.1/24',
          :advbase => '1',
          :advskew => '0',
          :pass    => 'TopSecret',
        }
      }
      it do
        should contain_bsd__network__interface('carp0')
        should contain_file('/etc/hostname.carp0').with_content(/inet 10.0.0.1 255.255.255.0 NONE\nvhid 1 pass TopSecret carpdev em0 advbase 1 advskew 0\nup\n/)
      end
    end
  end

  context "when a bad name is used" do
    let(:facts) { {:kernel => 'OpenBSD'} }
    let(:title) { 'notcorrect0' }
    let(:params) {
      {
        :id      => '1',
        :device  => 'em0',
        :address => '10.0.0.1/24',
        :advbase => '1',
        :advskew => '0',
        :pass    => 'TopSecret',
      }
    }
    it do
      expect {
          should contain_bsd__network__interface__carp('notcorrect0')
      }.to raise_error(Puppet::Error, /does not match/)
    end
  end
end
