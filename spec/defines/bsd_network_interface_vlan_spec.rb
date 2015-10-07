require 'spec_helper'

describe "bsd::network::interface::vlan" do
  context "on OpenBSD" do
    let(:facts) { {:kernel => 'OpenBSD'} }
    let(:title) { 'vlan0' }
    context " a minimal example" do
      let(:params) {
        {
          :id      => '1',
          :device  => 'em0',
          :address => '10.0.0.1/24',
        }
      }
      it do
        should contain_bsd__network__interface('vlan0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.vlan0').with_content(/vlan 1 vlandev em0\ninet 10.0.0.1 255.255.255.0 NONE\nup\n/)
      end
    end
    context " a minimal example with multiple addresses" do
      let(:params) {
        {
          :id      => '1',
          :device  => 'em0',
          :address => [ '10.0.0.1/24', '10.0.0.2/32', ],
        }
      }
      it do
        should contain_bsd__network__interface('vlan0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.vlan0').with_content(/vlan 1 vlandev em0\ninet 10.0.0.1 255.255.255.0 NONE\ninet alias 10.0.0.2 255.255.255.255 NONE\nup\n/)
      end
    end
    context " a bit more extensive example with values set" do
      let(:params) {
        {
          :id      => '1',
          :device  => 'em0',
          :address => '10.0.0.1/24',
          :values  => '!route add -net 10.10.10.0/24 10.0.0.254',
        }
      }
      it do
        should contain_bsd__network__interface('vlan0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.vlan0').with_content(/vlan 1 vlandev em0\ninet 10.0.0.1 255.255.255.0 NONE\n!route add -net 10.10.10.0\/24 10.0.0.254\nup\n/)
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
      }
    }
    it do
      expect {
          should contain_bsd__network__interface__vlan('notcorrect0')
      }.to raise_error(Puppet::Error, /does not match/)
    end
  end

  context "on FreeBSD" do
    let(:facts) { {:kernel => 'FreeBSD'} }
    let(:title) { 'vlan0' }
    context " a minimal example" do
      let(:params) {
        {
          :id      => '1',
          :device  => 'em0',
          :address => '10.0.0.1/24',
        }
      }
      it do
        should contain_bsd__network__interface('vlan0').with_parents(['em0'])
      end
      it do
        should contain_bsd__network__interface('vlan0').with_options(['vlan 1', 'vlandev em0'])
      end
      it do
        should contain_bsd__network__interface('vlan0').with_values(['10.0.0.1/24'])
      end
    end
  end
end
