require 'puppet_x/bsd/ifconfig'

describe 'PUppetX::BSD::Ifconfig' do
  context "on OpenBSD" do
    context '#parse' do
      it "should return the desired hash for a single interface" do
        output = File.read("spec/fixtures/ifconfig_openbsd.em.up")

        wanted = {:em0=>{:flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :inet6=>["fe80::200:9999:ffff:6404/64", "2fff:fff:ffff::10:10/64"], :inet=>"10.0.0.10/255.255.255.0"}}
        expect(PuppetX::BSD::Ifconfig.new(output).parse).to eq(wanted)
      end

      it "should return the desired hash for a full example" do
        output = File.read("spec/fixtures/ifconfig_openbsd.full")

        wanted = {:lo0=>{:flags=>["UP", "LOOPBACK", "RUNNING", "MULTICAST"], :mtu=>"32768", :inet6=>["fe80::1/64", "::1/128"], :inet=>"127.0.0.1/255.0.0.0"}, :em0=>{:flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :inet=>"10.0.31.2/255.255.255.252", :inet6=>["fe80::200:24ff:fed0:6404/64", "2001:1234:abcd:f::10/80"]}, :em1=>{:flags=>["BROADCAST", "SIMPLEX", "MULTICAST"], :mtu=>"1500"}, :em2=>{:flags=>["BROADCAST", "SIMPLEX", "MULTICAST"], :mtu=>"1500"}, :em3=>{:flags=>["BROADCAST", "SIMPLEX", "MULTICAST"], :mtu=>"1500"}, :vether0=>{:flags=>["UP", "BROADCAST", "RUNNING", "PROMISC", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :inet6=>["fe80::fce1:baff:fed0:7c4d/64", "2001:1234:abcd:0:1::/80", "fc04::/64"], :inet=>"10.0.31.238/255.255.255.240"}, :bridge0=>{:flags=>["UP", "RUNNING"]}, :pflog0=>{:flags=>["UP", "RUNNING", "PROMISC"], :mtu=>"33144"}, :bridge1=>{:flags=>["UP", "RUNNING"]}, :vlan88=>{:flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :inet6=>["fe80::fce1:baff:fed1:1338/64", "fc05::/64"]}, :vether1=>{:flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :mtu=>"1500"}}
        expect(PuppetX::BSD::Ifconfig.new(output).parse).to eq(wanted)
      end
    end

    context '#interfaces' do
      it "should return the interface list " do
        output = File.read("spec/fixtures/ifconfig_openbsd.full")

        should =  [
          "lo0",
          "em0",
          "em1",
          "em2",
          "em3",
          "em4",
          "em5",
          "em6",
          "em7",
          "enc0",
          "vether0",
          "bridge0",
          "pflog0",
          "bridge1",
          "vlan88",
          "vether1"
        ]

        expect(PuppetX::BSD::Ifconfig.new(output).interfaces).to eq(should)
      end
    end
  end
end
