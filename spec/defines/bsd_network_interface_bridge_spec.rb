require 'spec_helper'

describe 'bsd::network::interface::bridge' do
  context 'on OpenBSD' do
    let(:facts) { { kernel: 'OpenBSD' } }
    let(:title) { 'bridge0' }

    context ' a minimal example' do
      let(:params) do
        {
          interface: %w[em0 em1]
        }
      end

      it do
        is_expected.to contain_bsd__network__interface__bridge('bridge0')
        is_expected.to contain_bsd__network__interface('bridge0').with_parents(%w[em0 em1])
        is_expected.to contain_bsd_interface('bridge0')
      end
      it do
        is_expected.to contain_file('/etc/hostname.bridge0').with_content(%r{add em0\nadd em1\nup\n})
      end
    end

    context 'a medium example' do
      let(:params) do
        {
          interface: %w[em0 em1],
          description: 'TestNet'
        }
      end

      it do
        is_expected.to contain_bsd__network__interface('bridge0').with_parents(%w[em0 em1])
      end
      it do
        is_expected.to contain_file('/etc/hostname.bridge0').with_content(%r{description "TestNet"\nadd em0\nadd em1\nup\n})
      end
    end

    context ' a bit more extensive example with values set' do
      let(:params) do
        {
          interface: %w[em0 em1],
          raw_values: '!route add -net 10.10.10.0/24 10.0.0.254'
        }
      end

      it do
        is_expected.to contain_bsd__network__interface('bridge0').with_parents(%w[em0 em1])
      end
      it do
        is_expected.to contain_file('/etc/hostname.bridge0').with_content(%r{add em0\nadd em1\n!route add -net 10.10.10.0\/24 10.0.0.254\nup\n})
      end
    end
  end

  context 'when a bad name is used' do
    let(:facts) { { kernel: 'OpenBSD' } }
    let(:title) { 'notcorrect0' }
    let(:params) { { interface: %w[em0 em1], description: 'TestNet' } }

    it do
      expect do
        is_expected.to contain_bsd__network__interface__bridge('notcorrect0')
      end.to raise_error(Puppet::Error, %r{does not match})
    end
  end
end
