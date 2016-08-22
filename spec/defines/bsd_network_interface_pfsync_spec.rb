require 'spec_helper'

describe "bsd::network::interface::pfsync" do
  context "on OpenBSD" do
    let(:facts) { {:kernel => 'OpenBSD'} }
    let(:title) { 'pfsync0' }
    context "an example with all default values" do
      it do
        should contain_bsd__network__interface__pfsync('pfsync0')
        should contain_bsd__network__interface('pfsync0')
        should contain_bsd_interface('pfsync0')
      end
      it do
        should contain_file('/etc/hostname.pfsync0').with_content(/-syncdev -syncpeer maxupd 128 -defer\nup\n/)
      end
    end

    context "a minimal example" do
      let(:params) { {:syncdev => 'em0'} }
      it do
        should contain_bsd__network__interface('pfsync0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.pfsync0').with_content(/syncdev em0 -syncpeer maxupd 128 -defer\nup\n/)
      end
    end

    context "a medium example" do
      let(:params) { {:syncdev => 'em0', :description => "TestNet"} }
      it do
        should contain_bsd__network__interface('pfsync0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.pfsync0').with_content(/description \"TestNet\"\nsyncdev em0 -syncpeer maxupd 128 -defer\nup\n/)
      end
    end

    context "an example with syncpeer" do
      let(:params) { {
          :syncdev => 'em0',
          :syncpeer => '10.0.0.222',
      } }
      it do
        should contain_bsd__network__interface('pfsync0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.pfsync0').with_content(
          /syncdev em0 syncpeer 10.0.0.222 maxupd 128 -defer\nup\n/)
      end
    end

    context "an example with non-default maxupd and defer" do
      let(:params) { {
          :syncdev  => 'em0',
          :syncpeer => '10.0.0.222',
          :maxupd   => '156',
          :defer    => true,
      } }
      it do
        should contain_bsd__network__interface('pfsync0').with_parents(['em0'])
      end
      it do
        should contain_file('/etc/hostname.pfsync0').with_content(
          /syncdev em0 syncpeer 10.0.0.222 maxupd 156 defer\nup\n/)
      end
    end
  end

  context "when a bad name is used" do
    let(:facts) { {:kernel => 'OpenBSD'} }
    let(:title) { 'notcorrect0' }
    let(:params) { {
        :syncdev => 'em0',
        :description => "TestNet"
    } }
    it do
      expect {
          should contain_bsd__network__interface__pfsync('notcorrect0')
      }.to raise_error(Puppet::Error, /does not match/)
    end
  end
end
