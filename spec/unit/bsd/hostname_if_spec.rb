require 'puppet_x/bsd/hostname_if'

describe 'PuppetX::BSD::Hostname_if' do

  describe "validation" do
    it "should fail if no config is supplied" do
      c = {}
      expect { PuppetX::BSD::Hostname_if.new(c).content }.to raise_error
    end

    it "should fail when an unknown option is supplied" do
      c = {
        :foo => {}
      }
      expect { PuppetX::BSD::Hostname_if.new(c).content }.to raise_error
    end

    it "should fail if description is not a String" do
      c = {
        :desc => ["an","item","or","two"]
      }
      expect { PuppetX::BSD::Hostname_if.new(c).content }.to raise_error
    end

    it "should fail if values is not a String or an Array" do
      c = {
        :values => { "not" => "hash" }
      }
      expect { PuppetX::BSD::Hostname_if.new(c).content }.to raise_error
    end

    it "should fail if options is not a String or an Array" do
      c = {
        :options => { "not" => "hash" }
      }
      expect { PuppetX::BSD::Hostname_if.new(c).content }.to raise_error
    end

    it "should fail when garbage is passed in" do
      c = {
        :values => [
          'what is this junk?',
        ]
      }
      expect { PuppetX::BSD::Hostname_if.new(c).content }.to raise_error
    end
  end

  describe "content" do
    it "should append the options string on the first line when options are present" do
      c = {
        :options => "mtu 1500"
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to match(/mtu 1500/)
    end

    it "should append multiple options on the first line when multiple options are present" do
      c = {
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to match(/mtu 1500/)
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to match(/media 100baseTX/)
    end

    it "should append multiple options on the first line with a description" do
      c = {
        :desc => "Default interface",
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to match(/mtu 1500/)
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to match(/media 100baseTX/)
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to match(/Default interface/)
    end

    it "should set the the dynamic property of the interface is specified" do
      c = {
        :values => 'dhcp',
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^dhcp/)
    end

    context 'On OpenBSD 5.6' do
      context 'with rtsol given for IPv6' do
        it "should set the the dynamic property of the interface is specified for all AF keeping rtsol" do
          c = {
            :values => [
              'dhcp',
              'rtsol',
            ]
          }
          expect(Facter).to receive(:value).with('kernelversion').at_least(:once).and_return('5.6')
          expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^dhcp/)
          expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^rtsol/)
        end
      end
      context 'with inet6 autoconf given for IPv6' do
        it "should set the the dynamic property of the interface is specified for all AF setting rtsol for inet6" do
          c = {
            :values => [
              'dhcp',
              'inet6 autoconf',
            ]
          }
          expect(Facter).to receive(:value).with('kernelversion').at_least(:once).and_return('5.6')
          expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^dhcp/)
          expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^rtsol/)
        end
      end
    end

    context 'On OpenBSD 5.7' do
      context 'with rtsol given for IPv6' do
        it "should set the the dynamic property of the interface is specified for all AF setting inet6 autoconf for rtsol" do
          c = {
            :values => [
              'dhcp',
              'rtsol',
            ]
          }
          expect(Facter).to receive(:value).with('kernelversion').at_least(:once).and_return('5.7')
          expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^dhcp/)
          expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^inet6 autoconf/)
        end
      end
      context 'with inet6 autoconf given for IPv6' do
        it "should set the the dynamic property of the interface is specified for all AF keeping" do
          c = {
            :values => [
              'dhcp',
              'inet6 autoconf',
            ]
          }
          expect(Facter).to receive(:value).with('kernelversion').at_least(:once).and_return('5.7')
          expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^dhcp/)
          expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^inet6 autoconf/)
        end
      end
    end

    it "should set the primary interface address and prefix" do
      c = {
        :values => 'fc01::/7',
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/fc01:: 7/)
    end

    it "should set multiple interface addresses" do
      c = {
        :values => [
          '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64',
        ]
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/inet 123.123.123.123 255.255.255.248 NONE/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/inet alias 172.16.0.1 255.255.255.224 NONE/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/inet6 fc01:: 7/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/inet6 alias 2001:100:fed:beef:: 64/)
    end

    it "should set everything when provided" do
      c = {
        :desc => "Default interface",
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
        :values => [
          '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64',
        ]
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/inet 123.123.123.123 255.255.255.248 NONE/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/inet alias 172.16.0.1 255.255.255.224 NONE/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/inet6 fc01:: 7/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/inet6 alias 2001:100:fed:beef:: 64/)
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to match(/mtu 1500/)
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to match(/media 100baseTX/)
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to match(/Default interface/)
    end

    it "should clear the description string when called multiple times" do
      c = {
        :desc => "Default interface",
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
        :values => [
          '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64',
        ]
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to_not match(/Default interface.*Default interface/)
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to_not match(/Default interface.*Default interface/)
      expect(PuppetX::BSD::Hostname_if.new(c).content.split("\n").first).to_not match(/Default interface.*Default interface/)
    end

    it "should not raise error when options are :udnef" do
      c = {
        :desc    => :undef,
        :options => :undef,
        :values  => [
          '123.123.123.123/29',
          '172.16.0.1/27',
          'fc01::/7',
          '2001:100:fed:beef::/64',
        ]
      }
      expect { PuppetX::BSD::Hostname_if.new(c).content }.to_not raise_error
    end

    it "should support setting the interface to up" do
      c = {
        :values  => [
          'up',
        ]
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^up/)
    end

    it "should support setting the interface to down" do
      c = {
        :values  => [
          'down',
        ]
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^down/)
    end

    it "should support setting the interface to up and setting the description" do
      c = {
        :desc    => "I am an interface",
        :values  => [
          'up',
        ]
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^description "I am an interface"\nup/)
    end

    it "should support the !command syntax in the hostname.if(5) manpage" do
      c = {
        :desc   => "Uplink",
        :values => [
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
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/10.0.1.12 255.255.255.0/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/10.0.1.13 255.255.255.0/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/10.0.1.14 255.255.255.0/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/10.0.1.15 255.255.255.0/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/10.0.1.16 255.255.255.0/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^!route add 65.65.65.65 10.0.1.13$/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/^up$/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/media 100baseTX/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/description "?Uplink"?/)
    end

    it "should fail when the type is not a string" do
      c = {
        :type    => ['gif'],
        :desc    => "I am a tunnel interface",
        :values  => [
          'up',
        ]
      }
      expect { PuppetX::BSD::Hostname_if.new(c).content }.to raise_error
    end

    it "should support the gre interface type" do
      c = {
        :type    => 'gre',
        :values  => [
          '192.168.100.1 192.168.100.2 netmask 0xffffffff link0 up',
          'tunnel 10.0.1.30 10.0.1.31',
        ]
      }
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/192.168.100.1 192.168.100.2 netmask 0xffffffff link0 up/)
      expect(PuppetX::BSD::Hostname_if.new(c).content).to match(/tunnel 10.0.1.30 10.0.1.31/)
    end

    it "should support the tun interface type" do
      c = {
        :type    => 'tun',
        :values  => [
          'up',
          '!/usr/local/sbin/openvpn --daemon --config /etc/openvpn/vpn.ovpn --cd /etc/openvpn',
        ]
      }
      content = PuppetX::BSD::Hostname_if.new(c).content
      expect(content).to match(/^up$/)
      expect(content).to match(/^!\/usr\/local\/sbin\/openvpn/)
    end

  end
end
