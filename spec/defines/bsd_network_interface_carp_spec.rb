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
        should contain_bsd__network__interface('carp0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.carp0').with_content(/vhid 1 pass TopSecret carpdev em0 advbase 1 advskew 0\ninet 10.0.0.1 255.255.255.0 NONE\nup\n/)
      end
    end

    context " a bit more extensive example with values set" do
      let(:params) {
        {
          :id      => '1',
          :device  => 'em0',
          :address => '10.0.0.1/24',
          :advbase => '1',
          :advskew => '0',
          :pass    => 'TopSecret',
          :values  => '!route add -net 10.10.10.0/24 10.0.0.254',
        }
      }
      it do
        should contain_bsd__network__interface('carp0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.carp0').with_content(/vhid 1 pass TopSecret carpdev em0 advbase 1 advskew 0\ninet 10.0.0.1 255.255.255.0 NONE\n!route add -net 10.10.10.0\/24 10.0.0.254\nup\n/)
      end
    end

    context " a bit more extensive example with multiple values set" do
      let(:params) {
        {
          :id      => '1',
          :device  => 'em0',
          :address => '10.0.0.1/24',
          :advbase => '1',
          :advskew => '0',
          :pass    => 'TopSecret',
          :values  => [ '!route add -net 10.10.10.0/24 10.0.0.254', '!route add -net 10.20.10.0/24 10.0.0.254', ],
        }
      }
      it do
        should contain_bsd__network__interface('carp0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.carp0').with_content(/vhid 1 pass TopSecret carpdev em0 advbase 1 advskew 0\ninet 10.0.0.1 255.255.255.0 NONE\n!route add -net 10.10.10.0\/24 10.0.0.254\n!route add -net 10.20.10.0\/24 10.0.0.254\nup\n/)
      end
    end

    context " a bit more extensive example with multiple addresses" do
      let(:params) {
        {
          :id      => '1',
          :device  => 'em0',
          :address => [ '10.0.0.1/24', '10.0.0.2/32', '10.0.0.3/32' ],
          :advbase => '1',
          :advskew => '0',
          :pass    => 'TopSecret',
        }
      }
      it do
        should contain_bsd__network__interface('carp0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.carp0').with_content(/vhid 1 pass TopSecret carpdev em0 advbase 1 advskew 0\ninet 10.0.0.1 255.255.255.0 NONE\ninet alias 10.0.0.2 255.255.255.255 NONE\ninet alias 10.0.0.3 255.255.255.255 NONE\nup\n/)
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
