require 'spec_helper'

describe "bsd::network::interface::wifi" do
  let(:facts) { {:kernel => 'OpenBSD'} }
  let(:title) { 'athn0' }
  let(:params) { {:network_name => 'myssid', :network_key => 'mysecretkey'} }

  it do
    should contain_file('/etc/hostname.athn0').with_content(/nwid myssid wpakey mysecretkey\nup/)
  end
end

