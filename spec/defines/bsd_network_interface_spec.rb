require 'spec_helper'

describe 'bsd::network::interface' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'a basic configuration' do
        let(:title) { 'igb0' }
        let(:params) { { ensure: 'up' } }

        case facts[:osfamily]
        when 'FreeBSD'
          it do
            is_expected.to contain_bsd__network__interface('igb0').with_ensure('up')
            is_expected.to contain_bsd__network__interface('igb0').with_mtu(nil)
            is_expected.to contain_bsd__network__interface('igb0').with_parents(nil)
            is_expected.to contain_bsd_interface('igb0').with_ensure('up')
            is_expected.to contain_bsd_interface('igb0').with_mtu(nil)
            is_expected.to contain_bsd_interface('igb0').with_parents(nil)
          end
        end
      end

      context 'a basic configuration with an address' do
        let(:title) { 'igb0' }
        let(:params) { { addresses: ['10.0.0.1/24'], description: 'simple' } }

        case facts[:osfamily]
        when 'FreeBSD'
          it do
            is_expected.to contain_shellvar('ifconfig_igb0').with_value(%r{inet 10.0.0.1/24})
            is_expected.to contain_shellvar('ifconfig_igb0').with_target('/etc/rc.conf')
            is_expected.to contain_shellvar('ifconfig_igb0').that_notifies('Bsd_interface[igb0]')
            is_expected.to contain_bsd_interface('igb0').with_ensure('up')
            is_expected.to contain_bsd_interface('igb0').with_mtu(nil)
            is_expected.to contain_bsd_interface('igb0').with_parents(nil)
          end
        end
      end

      context 'a basic configuration with mtu' do
        let(:title) { 'igb0' }
        let(:params) { { mtu: 9000, description: 'simple mtu' } }

        case facts[:osfamily]
        when 'FreeBSD'
          it do
            is_expected.to contain_shellvar('ifconfig_igb0').with_value(%r{mtu 9000})
            is_expected.to contain_shellvar('ifconfig_igb0').with_target('/etc/rc.conf')
            is_expected.to contain_bsd_interface('igb0').with_ensure('up')
            is_expected.to contain_bsd_interface('igb0').with_mtu(9000)
            is_expected.to contain_bsd_interface('igb0').with_parents(nil)
          end
        end
      end

      context 'a basic vlan interface with an address' do
        let(:title) { 'vlan1' }
        let(:params) { { addresses: ['10.0.0.1/24'], options: ['vlan 1', 'vlandev em0'] } }

        case facts[:osfamily]
        when 'FreeBSD'
          it do
            is_expected.to contain_shellvar('ifconfig_vlan1').with_value(%r{inet 10.0.0.1/24 vlan 1 vlandev em0})
            is_expected.to contain_shellvar('ifconfig_vlan1').with_ensure('present')
            is_expected.to contain_shellvar('ifconfig_vlan1').that_notifies('Bsd_interface[vlan1]')
            is_expected.to contain_bsd_interface('vlan1').that_requires('Shellvar[ifconfig_vlan1]')
            is_expected.to contain_bsd__network__interface('vlan1')

            is_expected.to contain_bsd_interface('vlan1').with_ensure('up')
            is_expected.to contain_bsd_interface('vlan1').with_mtu(nil)
            is_expected.to contain_bsd_interface('vlan1').with_parents(nil)
          end
        end
      end
    end
  end

  context 'on OpenBSD' do
    let(:facts) { { kernel: 'OpenBSD' } }
    context 'a basic configuration' do
      let(:title) { 'tun0' }
      let(:params) { { raw_values: ['just a test', 'up'], description: 'simple' } }

      it do
        is_expected.to contain_file('/etc/hostname.tun0').with_content(%r{description "simple"\njust a test\nup\n})
        is_expected.to contain_bsd_interface('tun0').that_requires('File[/etc/hostname.tun0]')
        is_expected.to contain_bsd__network__interface('tun0')
      end
    end

    context 'a tun device' do
      let(:title) { 'tun0' }
      let(:params) { { raw_values: ['up', '!/usr/local/bin/openvpn'] } }

      it do
        is_expected.to contain_file('/etc/hostname.tun0').with_content(%r{up\n!/usr/local/bin/openvpn})
      end
      it do
        is_expected.to contain_file('/etc/hostname.tun0').that_notifies('Bsd_interface[tun0]')
      end
      it do
        is_expected.to contain_bsd_interface('tun0').that_requires('File[/etc/hostname.tun0]')
      end
    end

    context 'a vether device using addresses and values parameter' do
      let(:title) { 'vether0' }
      let(:params) do
        {
          addresses: ['123.123.123.123/29',
                      '172.16.0.1/27',
                      'fc01::/7',
                      '2001:100:fed:beef::/64'],
          raw_values: ['up']
        }
      end

      it do
        is_expected.to contain_file('/etc/hostname.vether0').with_content(%r{inet 123.123.123.123 255.255.255.248 NONE\ninet alias 172.16.0.1 255.255.255.224 NONE\ninet6 fc01:: 7\ninet6 alias 2001:100:fed:beef:: 64\nup\n})
      end
      it do
        is_expected.to contain_file('/etc/hostname.vether0').that_notifies('Bsd_interface[vether0]')
        is_expected.to contain_bsd_interface('vether0').that_requires('File[/etc/hostname.vether0]')
        is_expected.to contain_bsd__network__interface('vether0')
      end
    end

    context 'a vether device using values parameter only' do
      let(:title) { 'vether0' }
      let(:params) do
        {
          raw_values: ['123.123.123.123/29',
                       '172.16.0.1/27',
                       'fc01::/7',
                       '2001:100:fed:beef::/64',
                       'up']
        }
      end

      it do
        is_expected.to contain_file('/etc/hostname.vether0').with_content(%r{inet 123.123.123.123 255.255.255.248 NONE\ninet alias 172.16.0.1 255.255.255.224 NONE\ninet6 fc01:: 7\ninet6 alias 2001:100:fed:beef:: 64\nup\n})
      end
      it do
        is_expected.to contain_file('/etc/hostname.vether0').that_notifies('Bsd_interface[vether0]')
      end
      it do
        is_expected.to contain_bsd_interface('vether0').that_requires('File[/etc/hostname.vether0]')
      end
    end
  end
end
