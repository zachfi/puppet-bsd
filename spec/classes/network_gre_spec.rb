require 'spec_helper'

describe 'bsd::network::gre' do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }

    context "on #{os}" do
      context 'with allowed' do
        let(:params) do
          {
            allowed: true,
            wccp: false,
            mobileip: false
          }
        end

        it do
          is_expected.to contain_class('bsd::network::gre')
          is_expected.to contain_sysctl('net.inet.gre.allow').with_value('1')
          is_expected.to contain_sysctl('net.inet.gre.wccp').with_value('0')
          is_expected.to contain_sysctl('net.inet.mobileip.allow').with_value('0')
        end
      end

      context 'with wccp' do
        let(:params) do
          {
            allowed: false,
            wccp: true,
            mobileip: false
          }
        end

        it do
          is_expected.to contain_class('bsd::network::gre')
          is_expected.to contain_sysctl('net.inet.gre.allow').with_value('0')
          is_expected.to contain_sysctl('net.inet.gre.wccp').with_value('1')
          is_expected.to contain_sysctl('net.inet.mobileip.allow').with_value('0')
        end
      end

      context 'with mobileip' do
        let(:params) do
          {
            allowed: false,
            wccp: false,
            mobileip: true
          }
        end

        it do
          is_expected.to contain_class('bsd::network::gre')
          is_expected.to contain_sysctl('net.inet.gre.allow').with_value('0')
          is_expected.to contain_sysctl('net.inet.gre.wccp').with_value('0')
          is_expected.to contain_sysctl('net.inet.mobileip.allow').with_value('1')
        end
      end
    end
  end
end
