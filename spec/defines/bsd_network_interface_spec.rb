require 'spec_helper'

describe "bsd::network::interface" do
  let(:facts) { {:kernel => 'OpenBSD'} }
  let(:title) { 'tun0' }
  let(:params) { {:values => ['up','!/usr/local/bin/openvpn'] } }

  it do
    should contain_file('/etc/hostname.tun0').with_content(/up\n!\/usr\/local\/bin\/openvpn/)
  end
end
