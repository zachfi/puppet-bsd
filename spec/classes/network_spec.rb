require 'spec_helper'

describe 'bsd::network' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default params' do
        it do
          is_expected.to contain_class('bsd::network')
          is_expected.to contain_sysctl('net.inet6.ip6.forwarding').with_value('0')
          is_expected.to contain_sysctl('net.inet.ip.forwarding').with_value('0')
        end
      end

      context 'with forwarding enabled' do
        let(:params) { { v4forwarding: true, v6forwarding: true } }

        it do
          is_expected.to contain_class('bsd::network')
          is_expected.to contain_sysctl('net.inet6.ip6.forwarding').with_value('1')
          is_expected.to contain_sysctl('net.inet.ip.forwarding').with_value('1')
        end

        case facts[:osfamily]
        when 'FreeBSD'
          it do
            is_expected.to contain_shellvar('gateway_enable').with_value('YES')
            is_expected.to contain_shellvar('ipv6_gateway_enable').with_value('YES')
          end
        end
      end

      context 'with gateways set' do
        let(:params) { { v4gateway: '123.123.123.123', v6gateway: '123::' } }

        it do
          is_expected.to contain_class('bsd::network')
        end

        case facts[:osfamily]
        when 'FreeBSD'
          it do
            is_expected.to contain_shellvar('defaultrouter').with_value('123.123.123.123')
            is_expected.to contain_shellvar('ipv6_defaultrouter').with_value('123::')
          end
        when 'OpenBSD'
          it do
            is_expected.to contain_file('/etc/mygate')
          end
        end
      end
    end
  end
end
