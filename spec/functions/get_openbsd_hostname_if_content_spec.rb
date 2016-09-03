require 'spec_helper'

describe "get_openbsd_hostname_if_content" do

  context "with mtu set" do
    config = {
      "name" => 'em0',
      "mtu"  => 9000,
    }

    it { should run.with_params(config).and_return("mtu 9000") }
  end

  context "with an address set" do
    config = {
      "name"      => 'em0',
      "addresses" => ['fc01::/64'],
    }

    it { should run.with_params(config).and_return("inet6 fc01:: 64") }
  end

  context "tun interface" do
    config = {
      "name"       => 'tun0',
      "type"       => 'tun',
      "raw_values" => ['up','!/usr/local/bin/openvpn'],
    }

    it { should run.with_params(config).and_return("up\n!/usr/local/bin/openvpn") }
  end
end
