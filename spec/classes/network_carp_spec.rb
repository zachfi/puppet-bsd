require 'spec_helper'

describe 'bsd::network::carp' do
  on_supported_os.each do |os, facts|
    let(:facts) { facts }
    context "on #{os}" do
      context 'with allowed' do
        let(:params) { { allowed: true } }
        it do
          is_expected.to contain_class('bsd::network::carp')
          is_expected.to contain_sysctl('net.inet.carp.allow').with_value('1')
        end
      end

      context 'with preempt' do
        let(:params) { { preempt: true } }
        it do
          is_expected.to contain_class('bsd::network::carp')
          is_expected.to contain_sysctl('net.inet.carp.preempt').with_value('1')
        end
      end
    end
  end
end
