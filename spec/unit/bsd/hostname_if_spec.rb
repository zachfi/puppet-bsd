require 'pp'
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
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should match(/mtu 1500/)
    end

    it "should append multiple options on the first line when multiple options are present" do
      c = {
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
      }
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should match(/mtu 1500/)
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should match(/media 100baseTX/)
    end

    it "should append multiple options on the first line with a description" do
      c = {
        :desc => "Default interface",
        :options => [
          "mtu 1500",
          "media 100baseTX",
        ],
      }
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should match(/mtu 1500/)
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should match(/media 100baseTX/)
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should match(/Default interface/)
    end

    it "should set the the dynamic property of the interface is specified" do
      c = {
        :values => 'dhcp',
      }
      PuppetX::BSD::Hostname_if.new(c).content.should match(/^dhcp/)
    end

    it "should set the the dynamic property of the interface is specified for all AF" do
      c = {
        :values => [
          'dhcp',
          'rtsol',
        ]
      }
      PuppetX::BSD::Hostname_if.new(c).content.should match(/^dhcp/)
    end

    it "should set the primary interface address and prefix" do
      c = {
        :values => 'fc01::/7',
      }
      PuppetX::BSD::Hostname_if.new(c).content.should match(/fc01:: 7/)
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
      PuppetX::BSD::Hostname_if.new(c).content.should match(/inet 123.123.123.123 255.255.255.248 NONE/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/inet alias 172.16.0.1 255.255.255.224 NONE/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/inet6 fc01:: 7/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/inet6 alias 2001:100:fed:beef:: 64/)
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
      PuppetX::BSD::Hostname_if.new(c).content.should match(/inet 123.123.123.123 255.255.255.248 NONE/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/inet alias 172.16.0.1 255.255.255.224 NONE/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/inet6 fc01:: 7/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/inet6 alias 2001:100:fed:beef:: 64/)
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should match(/mtu 1500/)
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should match(/media 100baseTX/)
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should match(/Default interface/)
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
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should_not match(/Default interface.*Default interface/)
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should_not match(/Default interface.*Default interface/)
      PuppetX::BSD::Hostname_if.new(c).content.split("\n").first.should_not match(/Default interface.*Default interface/)
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
      PuppetX::BSD::Hostname_if.new(c).content.should match(/^up/)
    end

    it "should support setting the interface to down" do
      c = {
        :values  => [
          'down',
        ]
      }
      PuppetX::BSD::Hostname_if.new(c).content.should match(/^down/)
    end

    it "should support setting the interface to up and setting the description" do
      c = {
        :desc    => "I am an interface",
        :values  => [
          'up',
        ]
      }
      PuppetX::BSD::Hostname_if.new(c).content.should match(/^up.*I am an interface/)
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
      PuppetX::BSD::Hostname_if.new(c).content.should match(/10.0.1.12 255.255.255.0/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/10.0.1.13 255.255.255.0/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/10.0.1.14 255.255.255.0/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/10.0.1.15 255.255.255.0/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/10.0.1.16 255.255.255.0/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/^!route add 65.65.65.65 10.0.1.13$/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/^up$/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/media 100baseTX/)
      PuppetX::BSD::Hostname_if.new(c).content.should match(/description "?Uplink"?/)
    end

  end
end
