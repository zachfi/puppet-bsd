require 'spec_helper'

describe 'get_rc_conf_trunk' do
  context 'with a simple config' do
    desired = [
      'laggproto lacp',
      'laggport em0',
      'laggport em1'
    ]

    config = {
      'name'        => 'lagg0',
      'description' => 'Trees',
      'proto'       => 'lacp',
      'interface'   => %w[em0 em1],
      'address'     => [
        '10.0.1.12/24'
      ]
    }
    it { is_expected.to run.with_params(config).and_return(desired) }
  end
end
