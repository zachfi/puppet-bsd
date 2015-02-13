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
    end

    context "a tun device" do
      let(:title) { 'tun0' }
      let(:params) { {:values => ['up','!/usr/local/bin/openvpn'] } }

      it do
        should contain_file('/etc/hostname.tun0').with_content(/up\n!\/usr\/local\/bin\/openvpn/)
      end
    end
  end
end
