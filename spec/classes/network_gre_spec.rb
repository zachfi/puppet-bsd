require 'spec_helper'

describe 'bsd::network::gre' do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }
    context "on #{os}" do

      context 'with allowed' do
        let(:params) {{
          :allowed  => true,
          :wccp     => false,
          :mobileip => false,
        }}
        it do
          should contain_class('bsd::network::gre')
          should contain_sysctl('net.inet.gre.allow').with_value('1')
          should contain_sysctl('net.inet.gre.wccp').with_value('0')
          should contain_sysctl('net.inet.mobileip.allow').with_value('0')
        end
      end

      context 'with wccp' do
        let(:params) {{
          :allowed  => false,
          :wccp     => true,
          :mobileip => false,
        }}
        it do
          should contain_class('bsd::network::gre')
          should contain_sysctl('net.inet.gre.allow').with_value('0')
          should contain_sysctl('net.inet.gre.wccp').with_value('1')
          should contain_sysctl('net.inet.mobileip.allow').with_value('0')
        end
      end

      context 'with mobileip' do
        let(:params) {{
          :allowed  => false,
          :wccp     => false,
          :mobileip => true,
        }}
        it do
          should contain_class('bsd::network::gre')
          should contain_sysctl('net.inet.gre.allow').with_value('0')
          should contain_sysctl('net.inet.gre.wccp').with_value('0')
          should contain_sysctl('net.inet.mobileip.allow').with_value('1')
        end
      end

    end
  end
end
