require 'puppet_x/bsd/hostname_if/inet'

describe 'PuppetX::BSD::Hostname_if::Inet' do
  describe 'initialize' do
    it "should raise an error if argument is not of correct type" do
      a = {:one => '1'}
      expect { PuppetX::BSD::Hostname_if::Inet.new(a) }.to raise_error
    end

    it "should not raise an error if argument is of correct type" do
      a = ['10.0.0.0/24']
      expect { PuppetX::BSD::Hostname_if::Inet.new(a) }.to_not raise_error
      b = '10.0.0.0/24'
      expect { PuppetX::BSD::Hostname_if::Inet.new(b) }.to_not raise_error
    end
  end

  describe 'process' do
    it "should yield the the dynamic addressing is specified for all AF" do
      a = [
        'dhcp',
        'rtsol',
      ]
      expect {|b|
        PuppetX::BSD::Hostname_if::Inet.new(a).process(&b)
      }.to yield_successive_args('dhcp','rtsol')
    end

    it "should yield multiple addresses when specified" do
      a = [
        '123.123.123.123/29',
        '172.16.0.1/27',
        'fc01::/7',
        '2001:100:fed:beef::/64',
      ]

      expect {|b|
        PuppetX::BSD::Hostname_if::Inet.new(a).process(&b)
      }.to yield_successive_args(
        'inet 123.123.123.123 255.255.255.248 NONE',
        'inet alias 172.16.0.1 255.255.255.224 NONE',
        'inet6 fc01:: 7',
        'inet6 alias 2001:100:fed:beef:: 64'
      )
    end
  end
end
