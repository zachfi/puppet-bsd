require 'spec_helper'

describe 'get_rc_conf_vlan' do
  context 'with a simple config' do
    desired = ["vlan 1", "vlandev em0"]

    config = {
      "name"        => 'vlan1',
      "description" => "Trees",
      "device"      => 'em0',
      "id"          => 1,
      "address"     => [
        '10.0.1.12/24',
      ],
    }
    it { should run.with_params(config).and_return(desired) }
  end
end
