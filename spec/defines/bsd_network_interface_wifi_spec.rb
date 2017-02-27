require 'spec_helper'

describe 'bsd::network::interface::wifi' do
  let(:facts) { { kernel: 'OpenBSD' } }
  let(:title) { 'athn0' }

  context 'with minimal parameters' do
    let(:params) { { network_name: 'myssid', wpa_key: 'mysecretkey' } }

    it do
      is_expected.to contain_file('/etc/hostname.athn0').with_content(%r{nwid myssid wpakey mysecretkey\nup})
      is_expected.to contain_bsd__network__interface__wifi('athn0')
      is_expected.to contain_bsd__network__interface('athn0')
      is_expected.to contain_bsd_interface('athn0')
    end
  end

  context 'with more parameters' do
    let(:params) do
      { network_name: 'myssid',
        wpa_key: 'mysecretkey',
        description: 'something good',
        address: [
          '10.23.4.56/16',
          '2001:471:4336:ff::1/64'
        ],
        options: [
          'chan 1',
          'media OFDM54',
          'mode 11g',
          'mediaopt hostap'
        ] }
    end
    it do
      should_content = "inet 10.23.4.56 255.255.0.0 NONE\ninet6 2001:471:4336:ff::1 64\nnwid myssid wpakey mysecretkey chan 1 media OFDM54 mode 11g mediaopt hostap description \"something good\"\nup"
      is_expected.to contain_file('/etc/hostname.athn0').with_content(%r{#{should_content}})
    end
  end

  context ' a bit more extensive example with values set' do
    let(:params) do
      { network_name: 'myssid',
        wpa_key: 'mysecretkey',
        description: 'something good',
        address: [
          '10.23.4.56/16',
          '2001:471:4336:ff::1/64'
        ],
        options: [
          'chan 1',
          'media OFDM54',
          'mode 11g',
          'mediaopt hostap'
        ],
        raw_values: '!route add -net 10.10.10.0/24 10.0.0.254' }
    end
    it do
      should_content = "inet 10.23.4.56 255.255.0.0 NONE\ninet6 2001:471:4336:ff::1 64\nnwid myssid wpakey mysecretkey chan 1 media OFDM54 mode 11g mediaopt hostap description \"something good\"\n!route add -net 10.10.10.0\/24 10.0.0.254\nup"
      is_expected.to contain_file('/etc/hostname.athn0').with_content(%r{#{should_content}})
    end
  end
end
