require 'puppet_x/bsd/hostname_if'

describe 'Hostname_if' do
  subject(:hif) { Hostname_if }

  describe 'initialize' do
    context 'when minimal configuration is passed' do
      it 'should not error' do
        expect { hif.new({:desc => 'String goes here'}) }.to_not raise_error
      end
    end
  end

  describe "content" do
    it "should append the options string on the first line when options are present" do
      c = {
        :options => ["mtu 1500"]
      }
      expect(hif.new(c).content.split("\n").first).to match(/mtu 1500/)
    end

    it "should append multiple options on the first line when multiple options are present" do
      c = {
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
      }
      expect(hif.new(c).content.split("\n").first).to match(/mtu 1500/)
      expect(hif.new(c).content.split("\n").first).to match(/media 100baseTX/)
    end

    it "should append multiple options on the first line with a description" do
      c = {
        :desc => "Default interface",
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
      }
      expect(hif.new(c).content.split("\n").first).to match(/mtu 1500/)
      expect(hif.new(c).content.split("\n").first).to match(/media 100baseTX/)
      expect(hif.new(c).content.split("\n").first).to match(/Default interface/)
    end

    it "should set the the dynamic property of the interface is specified" do
      c = {
        :raw_values => ['dhcp'],
      }
      expect(hif.new(c).content).to match(/^dhcp/)
    end

    context 'with rtsol given for IPv6' do
      it "should set the the dynamic property of the interface is specified for all AF setting inet6 autoconf for rtsol" do
        c = {
          :raw_values => [
            'dhcp',
            'rtsol',
          ]
        }
        expect(hif.new(c).content).to match(/^dhcp/)
        expect(hif.new(c).content).to match(/^rtsol/)
      end
    end

    it "should set the primary interface address and prefix" do
      c = {
        :raw_values => ['fc01::/7'],
      }
      expect(hif.new(c).content).to match(/fc01:: 7/)
    end

    it "should set multiple interface addresses" do
      c = {
        :raw_values => [
          '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64',
        ]
      }
      expect(hif.new(c).content).to match(/inet 123.123.123.123 255.255.255.248 NONE/)
      expect(hif.new(c).content).to match(/inet alias 172.16.0.1 255.255.255.224 NONE/)
      expect(hif.new(c).content).to match(/inet6 fc01:: 7/)
      expect(hif.new(c).content).to match(/inet6 alias 2001:100:fed:beef:: 64/)
    end

    it "should set everything when provided" do
      c = {
        :desc => "Default interface",
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
        :raw_values => [
          '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64',
        ]
      }
      expect(hif.new(c).content).to match(/inet 123.123.123.123 255.255.255.248 NONE/)
      expect(hif.new(c).content).to match(/inet alias 172.16.0.1 255.255.255.224 NONE/)
      expect(hif.new(c).content).to match(/inet6 fc01:: 7/)
      expect(hif.new(c).content).to match(/inet6 alias 2001:100:fed:beef:: 64/)
      expect(hif.new(c).content.split("\n").first).to match(/mtu 1500/)
      expect(hif.new(c).content.split("\n").first).to match(/media 100baseTX/)
      expect(hif.new(c).content.split("\n").first).to match(/Default interface/)
    end

    it "should clear the description string when called multiple times" do
      c = {
        :desc => "Default interface",
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
        :raw_values => [
          '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64',
        ]
      }
      expect(hif.new(c).content.split("\n").first).to_not match(/Default interface.*Default interface/)
      expect(hif.new(c).content.split("\n").first).to_not match(/Default interface.*Default interface/)
      expect(hif.new(c).content.split("\n").first).to_not match(/Default interface.*Default interface/)
    end

    it "should not raise error when options are :udnef" do
      c = {
        :desc    => :undef,
        :options => :undef,
        :raw_values  => [
          '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64',
        ]
      }
      expect { hif.new(c).content }.to_not raise_error
    end

    it "should support setting the interface to up" do
      c = {
        :raw_values  => [
          'up',
        ]
      }
      expect(hif.new(c).content).to match(/^up/)
    end

    it "should support setting the interface to down" do
      c = {
        :raw_values  => [
          'down',
        ]
      }
      expect(hif.new(c).content).to match(/^down/)
    end

    it "should support setting the interface to up and setting the description" do
      c = {
        :desc    => "I am an interface",
        :raw_values  => [
          'up',
        ]
      }
      expect(hif.new(c).content).to match(/^description "I am an interface"\nup/)
    end

    it "should support the !command syntax in the hostname.if(5) manpage" do
      c = {
        :desc   => "Uplink",
        :raw_values => [
          '10.0.1.12/24',
          '10.0.1.13/24',
          '10.0.1.14/24',
          '10.0.1.15/24',
          '10.0.1.16/24',
          '!route add 65.65.65.65 10.0.1.13',
          'up',
        ],
        :options => [
          'media 100baseTX'
        ]
      }
      expect(hif.new(c).content).to match(/10.0.1.12 255.255.255.0/)
      expect(hif.new(c).content).to match(/10.0.1.13 255.255.255.0/)
      expect(hif.new(c).content).to match(/10.0.1.14 255.255.255.0/)
      expect(hif.new(c).content).to match(/10.0.1.15 255.255.255.0/)
      expect(hif.new(c).content).to match(/10.0.1.16 255.255.255.0/)
      expect(hif.new(c).content).to match(/^!route add 65.65.65.65 10.0.1.13$/)
      expect(hif.new(c).content).to match(/^up$/)
      expect(hif.new(c).content).to match(/media 100baseTX/)
      expect(hif.new(c).content).to match(/description "?Uplink"?/)
    end

    it "should fail when the type is not a string" do
      c = {
        :type    => ['gif'],
        :desc    => "I am a tunnel interface",
        :raw_values  => [
          'up',
        ]
      }
      expect { hif.new(c).content }.to raise_error(ArgumentError, /Config option.*must be a String/)
    end

    it "should support the gre interface type" do
      c = {
        :type    => 'gre',
        :raw_values  => [
          '192.168.100.1 192.168.100.2 netmask 0xffffffff link0 up',
          'tunnel 10.0.1.30 10.0.1.31',
        ]
      }
      expect(hif.new(c).content).to match(/192.168.100.1 192.168.100.2 netmask 0xffffffff link0 up/)
      expect(hif.new(c).content).to match(/tunnel 10.0.1.30 10.0.1.31/)
    end

    it "should support the tun interface type" do
      c = {
        :type    => 'tun',
        :raw_values  => [
          'up',
          '!/usr/local/sbin/openvpn --daemon --config /etc/openvpn/vpn.ovpn --cd /etc/openvpn',
        ]
      }
      content = hif.new(c).content
      expect(content).to match(/^up$/)
      expect(content).to match(/^!\/usr\/local\/sbin\/openvpn/)
    end

  end
end
