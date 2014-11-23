require 'spec_helper'

describe "get_openbsd_hostname_if_content" do

  context "tun interface" do
    config = {
      'name' => 'tun0',
      'type' => 'tun',
      'values' => ['up','!/usr/local/bin/openvpn'],
    }

    it { should run.with_params(config).and_return("up\n!/usr/local/bin/openvpn") }
  end
end
