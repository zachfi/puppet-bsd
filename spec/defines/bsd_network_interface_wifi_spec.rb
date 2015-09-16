require 'spec_helper'

describe "bsd::network::interface::wifi" do
  let(:facts) { {:kernel => 'OpenBSD'} }
  let(:title) { 'athn0' }

  context "with minimal paramaters" do
    let(:params) { {:network_name => 'myssid', :network_key => 'mysecretkey'} }

    it do
      should contain_file('/etc/hostname.athn0').with_content(/nwid myssid wpakey mysecretkey\nup/)
    end
  end

  context "with minimal paramaters" do
    let(:params) { {:network_name => 'myssid',
                    :network_key => 'mysecretkey',
                    :description => 'something good',
                    :address => [
                      '10.23.4.56/16',
                      '2001:471:4336:ff::1/64',
                    ],
                    :options => [
                      'chan 1',
                      'media OFDM54',
                      'mode 11g',
                      'mediaopt hostap',
                    ]
      }
    }
    it do
      should_content =  "inet 10.23.4.56 255.255.0.0 NONE\ninet6 2001:471:4336:ff::1 64\nnwid myssid wpakey mysecretkey chan 1 media OFDM54 mode 11g mediaopt hostap description \"something good\"\nup"
      should contain_file('/etc/hostname.athn0').with_content(/#{should_content}/)
    end
  end

  context " a bit more extensive example with values set" do
    let(:params) { {:network_name => 'myssid',
                    :network_key => 'mysecretkey',
                    :description => 'something good',
                    :address => [
                      '10.23.4.56/16',
                      '2001:471:4336:ff::1/64',
                    ],
                    :options => [
                      'chan 1',
                      'media OFDM54',
                      'mode 11g',
                      'mediaopt hostap',
                    ],
                    :values  => '!route add -net 10.10.10.0/24 10.0.0.254',
      }
    }
    it do
      should_content =  "inet 10.23.4.56 255.255.0.0 NONE\ninet6 2001:471:4336:ff::1 64\nnwid myssid wpakey mysecretkey chan 1 media OFDM54 mode 11g mediaopt hostap description \"something good\"\n!route add -net 10.10.10.0\/24 10.0.0.254\nup"
      should contain_file('/etc/hostname.athn0').with_content(/#{should_content}/)
    end
  end
end

