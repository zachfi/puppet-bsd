require 'spec_helper'

describe "bsd::network::interface" do
  context "on OpenBSD" do
    let(:facts) { {:kernel => 'OpenBSD'} }
    context "a basic configuration" do
      let(:title) { 'tun0' }
      let(:params) { {:values => ['just a test', 'up'], :description => 'simple' } }

      it do
        should contain_file('/etc/hostname.tun0').with_content(/description "simple"\njust a test\nup\n/)
      end
      it do
        should contain_bsd_interface('tun0').that_requires('File[/etc/hostname.tun0]')
      end
    end

    context "a tun device" do
      let(:title) { 'tun0' }
      let(:params) { {:values => ['up','!/usr/local/bin/openvpn'] } }

      it do
        should contain_file('/etc/hostname.tun0').with_content(/up\n!\/usr\/local\/bin\/openvpn/)
      end
      it do
        should contain_file('/etc/hostname.tun0').that_notifies('Bsd_interface[tun0]')
      end
      it do
        should contain_bsd_interface('tun0').that_requires('File[/etc/hostname.tun0]')
      end
    end

    context "a vether device using addresses and values parameter" do
      let(:title) { 'vether0' }
      let(:params) { {
        :addresses => [ '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64', ],
        :values => [ 'up', ]
        }
      }

      it do
        should contain_file('/etc/hostname.vether0').with_content(/inet 123.123.123.123 255.255.255.248 NONE\ninet alias 172.16.0.1 255.255.255.224 NONE\ninet6 fc01:: 7\ninet6 alias 2001:100:fed:beef:: 64\nup\n/)
      end
      it do
        should contain_file('/etc/hostname.vether0').that_notifies('Bsd_interface[vether0]')
      end
      it do
        should contain_bsd_interface('vether0').that_requires('File[/etc/hostname.vether0]')
      end
    end

    context "a vether device using values parameter only" do
      let(:title) { 'vether0' }
      let(:params) { {
        :values => [ '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64',
          'up', ]
        }
      }

      it do
        should contain_file('/etc/hostname.vether0').with_content(/inet 123.123.123.123 255.255.255.248 NONE\ninet alias 172.16.0.1 255.255.255.224 NONE\ninet6 fc01:: 7\ninet6 alias 2001:100:fed:beef:: 64\nup\n/)
      end
      it do
        should contain_file('/etc/hostname.vether0').that_notifies('Bsd_interface[vether0]')
      end
      it do
        should contain_bsd_interface('vether0').that_requires('File[/etc/hostname.vether0]')
      end
    end
  end

  context "on FreeBSD" do
    let(:facts) { {:kernel => 'FreeBSD'} }
    context "a basic configuration" do
      let(:title) { 'igb0' }
      let(:params) { {:values => ['10.0.0.1/24'], :description => 'simple' } }

      it do
        should contain_shellvar('ifconfig_igb0').with_value(/inet 10.0.0.1\/24/)
      end
      it do
        should contain_shellvar('ifconfig_igb0').that_notifies('Bsd_interface[igb0]')
      end
      it do
        should contain_bsd_interface('igb0').that_requires('Shellvar[ifconfig_igb0]')
      end
    end

    context "when processing a vlan interface with one address" do
      let(:title) { 'vlan1' }
      let(:params) { {:values => ['10.0.0.1/24'], :options => ['vlan 1', 'vlandev em0'] } }

      it do
        should contain_shellvar('ifconfig_vlan1').with_value(/inet 10.0.0.1\/24 vlan 1 vlandev em0/)
      end
      it do
        should contain_shellvar('ifconfig_vlan1').with_ensure('present')
      end
      it do
        should contain_shellvar('ifconfig_vlan1').that_notifies('Bsd_interface[vlan1]')
      end
      it do
        should contain_bsd_interface('vlan1').that_requires('Shellvar[ifconfig_vlan1]')
      end
    end
  end
end
