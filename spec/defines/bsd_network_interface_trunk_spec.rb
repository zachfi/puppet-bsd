require 'spec_helper'

describe 'bsd::network::interface::trunk' do
  context 'on OpenBSD' do
    let(:facts) { { kernel: 'OpenBSD' } }
    let(:title) { 'trunk0' }
    context ' a minimal example' do
      let(:params) { { interface: %w(em0 em1) } }
      it do
        is_expected.to contain_bsd__network__interface__trunk('trunk0')
        is_expected.to contain_bsd__network__interface('trunk0').with_parents(%w(em0 em1))
        is_expected.to contain_bsd_interface('trunk0')
      end
      it do
        is_expected.to contain_file('/etc/hostname.trunk0').with_content(%r{trunkproto lacp trunkport em0 trunkport em1\nup\n})
      end
    end

    context 'a medium example' do
      let(:params) { { interface: %w(em0 em1), description: 'TestNet' } }
      it do
        is_expected.to contain_bsd__network__interface('trunk0').with_parents(%w(em0 em1))
      end
      it do
        is_expected.to contain_file('/etc/hostname.trunk0').with_content(%r{description \"TestNet\"\ntrunkproto lacp trunkport em0 trunkport em1\nup\n})
      end
    end

    context 'an example with an address' do
      let(:params) do
        {
          interface: %w(em0 em1),
          description: 'TestNet',
          address: ['fc01::/64']
        }
      end
      it do
        is_expected.to contain_bsd__network__interface('trunk0').with_parents(%w(em0 em1))
      end
      it do
        is_expected.to contain_file('/etc/hostname.trunk0').with_content(
          %r{description \"TestNet\"\ntrunkproto lacp trunkport em0 trunkport em1\ninet6 fc01:: 64\nup\n}
        )
      end
    end

    context 'an example with multiple addresses' do
      let(:params) do
        {
          interface: %w(em0 em1),
          description: 'TestNet',
          address: ['fc01::/64', '10.0.0.1/24']
        }
      end
      it do
        is_expected.to contain_bsd__network__interface('trunk0').with_parents(%w(em0 em1))
      end
      it do
        is_expected.to contain_file('/etc/hostname.trunk0').with_content(
          %r{description \"TestNet\"\ntrunkproto lacp trunkport em0 trunkport em1\ninet6 fc01:: 64\ninet 10.0.0.1 255.255.255.0 NONE\nup\n}
        )
      end
    end
  end

  context 'when a bad name is used' do
    let(:facts) { { kernel: 'OpenBSD' } }
    let(:title) { 'notcorrect0' }
    let(:params) { { interface: %w(em0 em1), description: 'TestNet' } }
    it do
      expect do
        is_expected.to contain_bsd__network__interface__trunk('notcorrect0')
      end.to raise_error(Puppet::Error, %r{does not match})
    end
  end
end
