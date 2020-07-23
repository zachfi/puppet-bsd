require 'spec_helper'

describe 'bsd::network::interface::bridge' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts.merge(cloned_interfaces: ['bridge']) }
      let(:title) { 'bridge0' }

      context ' a minimal example' do
        let(:params) do
          {
            interface: %w[em0 em1]
          }
        end

        case facts[:osfamily]
        when 'OpenBSD'
          it do
            is_expected.to contain_bsd__network__interface__bridge('bridge0')
            is_expected.to contain_bsd__network__interface('bridge0').with_parents(%w[em0 em1])
            is_expected.to contain_bsd_interface('bridge0')
            is_expected.to contain_file('/etc/hostname.bridge0').with_content(%r{add em0\nadd em1\nup\n})
          end
        when 'FreeBSD'
          it do
            is_expected.to contain_bsd__network__interface('bridge0').with_parents(%w[em0 em1])
            is_expected.to contain_shellvar('ifconfig_bridge0').with_value(%r{addm em0 addm em1})
            is_expected.to contain_shellvar('cloned_interfaces_bridge0').with_value('bridge0')
          end
        end
      end

      context 'a medium example' do
        let(:params) do
          {
            interface: %w[em0 em1],
            description: 'TestNet'
          }
        end

        case facts[:osfamily]
        when 'OpenBSD'
          it do
            is_expected.to contain_bsd__network__interface('bridge0').with_parents(%w[em0 em1])
          end

          it do
            is_expected.to contain_file('/etc/hostname.bridge0').with_content(%r{description "TestNet"\nadd em0\nadd em1\nup\n})
          end
        end
      end

      context ' a bit more extensive example with values set' do
        let(:params) do
          {
            interface: %w[em0 em1],
            raw_values: '!route add -net 10.10.10.0/24 10.0.0.254'
          }
        end

        case facts[:osfamily]
        when 'OpenBSD'
          it do
            is_expected.to contain_bsd__network__interface('bridge0').with_parents(%w[em0 em1])
          end
          it do
            is_expected.to contain_file('/etc/hostname.bridge0').with_content(/add em0\nadd em1\n!route add -net 10.10.10.0\/24 10.0.0.254\nup\n/)
          end
        end
      end

      context 'when a bad name is used' do
        let(:title) { 'notcorrect0' }
        let(:params) { { interface: %w[em0 em1], description: 'TestNet' } }

        case facts[:osfamily]
        when 'OpenBSD'
          it do
            expect do
              is_expected.to contain_bsd__network__interface__bridge('notcorrect0')
            end.to raise_error(Puppet::Error, %r{does not match})
          end
        end
      end

    end
  end
end
