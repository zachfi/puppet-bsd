require 'spec_helper'

describe 'bsd::network::interface::pfsync' do
  context 'on OpenBSD' do
    let(:facts) { { kernel: 'OpenBSD' } }
    let(:title) { 'pfsync0' }
    context 'an example with all default values' do
      it do
        is_expected.to contain_bsd__network__interface__pfsync('pfsync0')
        is_expected.to contain_bsd__network__interface('pfsync0')
        is_expected.to contain_bsd_interface('pfsync0')
      end
      it do
        is_expected.to contain_file('/etc/hostname.pfsync0').with_content(%r{-syncdev -syncpeer maxupd 128 -defer\nup\n})
      end
    end

    context 'a minimal example' do
      let(:params) { { syncdev: 'em0' } }
      it do
        is_expected.to contain_bsd__network__interface('pfsync0').with_parents(['em0'])
      end
      it do
        is_expected.to contain_file('/etc/hostname.pfsync0').with_content(%r{syncdev em0 -syncpeer maxupd 128 -defer\nup\n})
      end
    end

    context 'a medium example' do
      let(:params) { { syncdev: 'em0', description: 'TestNet' } }
      it do
        is_expected.to contain_bsd__network__interface('pfsync0').with_parents(['em0'])
      end
      it do
        is_expected.to contain_file('/etc/hostname.pfsync0').with_content(%r{description \"TestNet\"\nsyncdev em0 -syncpeer maxupd 128 -defer\nup\n})
      end
    end

    context 'an example with syncpeer' do
      let(:params) do
        {
          syncdev: 'em0',
          syncpeer: '10.0.0.222'
        }
      end
      it do
        is_expected.to contain_bsd__network__interface('pfsync0').with_parents(['em0'])
      end
      it do
        is_expected.to contain_file('/etc/hostname.pfsync0').with_content(
          %r{syncdev em0 syncpeer 10.0.0.222 maxupd 128 -defer\nup\n}
        )
      end
    end

    context 'an example with non-default maxupd and defer' do
      let(:params) do
        {
          syncdev: 'em0',
          syncpeer: '10.0.0.222',
          maxupd: '156',
          defer: true
        }
      end
      it do
        is_expected.to contain_bsd__network__interface('pfsync0').with_parents(['em0'])
      end
      it do
        is_expected.to contain_file('/etc/hostname.pfsync0').with_content(
          %r{syncdev em0 syncpeer 10.0.0.222 maxupd 156 defer\nup\n}
        )
      end
    end
  end

  context 'when a bad name is used' do
    let(:facts) { { kernel: 'OpenBSD' } }
    let(:title) { 'notcorrect0' }
    let(:params) do
      {
        syncdev: 'em0',
        description: 'TestNet'
      }
    end
    it do
      expect do
        is_expected.to contain_bsd__network__interface__pfsync('notcorrect0')
      end.to raise_error(Puppet::Error, %r{does not match})
    end
  end
end
