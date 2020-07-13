require 'puppet_x/bsd/ifconfig'

describe 'PuppetX::BSD::Ifconfig' do
  context 'on OpenBSD' do
    context '#parse' do
      it 'returns the desired hash for a single interface' do
        output = File.read('spec/fixtures/ifconfig_openbsd.em.up')

        wanted = {:em0=>{:flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :groups=>["egress"], :status=>"active", :inet6=>["fe80::200:9999:ffff:6404/64", "2fff:fff:ffff::10:10/64"], :inet=>"10.0.0.10/255.255.255.0"}}
        expect(PuppetX::BSD::Ifconfig.new(output).parse).to eq(wanted)
      end

      it 'returns the desired hash for a full example' do
        output = File.read('spec/fixtures/ifconfig_openbsd.full')

        wanted = {:lo0=>{:flags=>["UP", "LOOPBACK", "RUNNING", "MULTICAST"], :mtu=>"32768", :groups=>["lo"], :inet6=>["fe80::1/64", "::1/128"], :inet=>"127.0.0.1/255.0.0.0"}, :em0=>{:flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :groups=>["egress"], :status=>"active", :inet=>"10.0.31.2/255.255.255.252", :inet6=>["fe80::200:24ff:fed0:6404/64", "2001:1234:abcd:f::10/80"]}, :em1=>{:flags=>["BROADCAST", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :status=>"active"}, :em2=>{:flags=>["BROADCAST", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :status=>"no"}, :em3=>{:flags=>["BROADCAST", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :status=>"no"}, :em4=>{:flags=>["UP", "BROADCAST", "RUNNING", "PROMISC", "ALLMULTI", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :status=>"active"}, :em5=>{:flags=>["UP", "BROADCAST", "RUNNING", "PROMISC", "ALLMULTI", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :status=>"no"}, :em6=>{:flags=>["UP", "BROADCAST", "RUNNING", "PROMISC", "ALLMULTI", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :status=>"no"}, :em7=>{:flags=>["UP", "BROADCAST", "RUNNING", "PROMISC", "ALLMULTI", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :status=>"active"}, :enc0=>{:groups=>["enc"], :status=>"active"}, :vether0=>{:flags=>["UP", "BROADCAST", "RUNNING", "PROMISC", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :groups=>["vether"], :status=>"active", :inet6=>["fe80::fce1:baff:fed0:7c4d/64", "2001:1234:abcd:0:1::/80", "fc04::/64"], :inet=>"10.0.31.238/255.255.255.240"}, :bridge0=>{:flags=>["UP", "RUNNING"], :groups=>["bridge"]}, :pflog0=>{:flags=>["UP", "RUNNING", "PROMISC"], :mtu=>"33144", :groups=>["pflog"]}, :bridge1=>{:flags=>["UP", "RUNNING"], :groups=>["bridge"]}, :vlan88=>{:flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :groups=>["vlan"], :status=>"active", :inet6=>["fe80::fce1:baff:fed1:1338/64", "fc05::/64"]}, :vether1=>{:flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :mtu=>"1500", :groups=>["vether"], :status=>"active"}}

        expect(PuppetX::BSD::Ifconfig.new(output).parse).to eq(wanted)
      end
    end

    context '#interfaces' do
      it 'returns the interface list' do
        output = File.read('spec/fixtures/ifconfig_openbsd.full')

        should = %w[lo0 em0 em1 em2 em3 em4 em5 em6
                    em7 enc0 vether0 bridge0 pflog0 bridge1
                    vlan88 vether1]

        expect(PuppetX::BSD::Ifconfig.new(output).interfaces).to eq(should)
      end
    end
  end

  context 'on FreeBSD' do
    context '#parse' do
      it 'returns the desired hash for a single interface' do
        output = File.read('spec/fixtures/ifconfig_freebsd.em.up')

        wanted = {:em0=>{:flags=>["UP", "BROADCAST", "RUNNING", "SIMPLEX", "MULTICAST"], :metric=>"0", :mtu=>"9000", :inet=>"10.0.0.10/255.255.255.0", :inet6=>["fe80::225:9999:ffff:ac26/64", "2fff:fff:ffff:1ab::10:10/64"], :status=>"active"}}
        expect(PuppetX::BSD::Ifconfig.new(output).parse).to eq(wanted)
      end

      it 'returns the desired hash for a full example' do
        output = File.read('spec/fixtures/ifconfig_freebsd.full')

        wanted = { igb0: { flags: %w[UP BROADCAST RUNNING SIMPLEX MULTICAST],
                           metric: '0',
                           mtu: '1500',
                           status: 'active',
                           inet: ['10.0.0.21/255.255.255.0',
                                  '10.0.0.124/255.255.255.255',
                                  '10.0.0.125/255.255.255.255'],
                           inet6: ['fe80::225:90ff:fe5c:f7cc/64',
                                   '2fff:fff:ffff::100/64',
                                   '2fff:fff:ffff::103/128',
                                   '2fff:fff:ffff::106/128',
                                   '2fff:fff:ffff::5/128',
                                   '2fff:fff:ffff::105/128',
                                   '2fff:fff:ffff::109/128',
                                   '2fff:fff:ffff::7/128'] },
                   igb1: { flags: %w[BROADCAST OACTIVE SIMPLEX MULTICAST],
                           metric: '0',
                           mtu: '1500',
                           status: 'active' },
                   lo0: { flags: %w[UP LOOPBACK RUNNING MULTICAST],
                          metric: '0',
                          mtu: '16384',
                          inet6: ['::1/128',
                                  'fe80::1/64'],
                          inet: '127.0.0.1/255.0.0.0' },

                   'vnet0.13': { flags: %w[UP BROADCAST RUNNING PROMISC SIMPLEX MULTICAST],
                               metric: '0',
                               mtu: '1500',
                               inet6: 'fe80::aaaa:bbbb:bbbb:bbbb/64',
                               groups: %w[epair testgroup],
                               status: 'active' },
                    pflog0: {metric:"0", mtu:"33160", groups:["pflog"]}
        }

        expect(PuppetX::BSD::Ifconfig.new(output).parse).to eq(wanted)
      end
    end
  end
end
