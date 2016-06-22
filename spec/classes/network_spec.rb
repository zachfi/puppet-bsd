require 'spec_helper'

describe 'bsd::network' do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }
    context "on #{os}" do
      context 'with default params' do
        it {
          should contain_class('bsd::network')
          should contain_sysctl('net.inet6.ip6.forwarding').with_value('0')
          should contain_sysctl('net.inet.ip.forwarding').with_value('0')
        }
      end

      context 'with forwarding enabled' do
        let(:params) { {:v4forwarding => true, :v6forwarding => true} }
        it {
          should contain_class('bsd::network')
          should contain_sysctl('net.inet6.ip6.forwarding').with_value('1')
          should contain_sysctl('net.inet.ip.forwarding').with_value('1')
        }

        case facts[:osfamily]
        when 'FreeBSD'
          it {
            should contain_shellvar('gateway_enable').with_value('YES')
            should contain_shellvar('ipv6_gateway_enable').with_value('YES')
          }
        end

      end

      context 'with gateways set' do
        let(:params) { {:v4gateway => '123.123.123.123', :v6gateway => '123::'} }
        it {
          should contain_class('bsd::network')
        }
        case facts[:osfamily]
        when 'FreeBSD'
          it {
            should contain_shellvar('defaultrouter').with_value('123.123.123.123')
            should contain_shellvar('ipv6_defaultrouter').with_value('123::')
          }
        when 'OpenBSD'
          it {
            should contain_file('/etc/mygate')
          }
        end

      end

    end
  end
end

