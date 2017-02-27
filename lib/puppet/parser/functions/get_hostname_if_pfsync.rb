require_relative '../../../puppet_x/bsd/hostname_if/pfsync'

module Puppet::Parser::Functions
  newfunction(:get_hostname_if_pfsync,
              type: :rvalue) do |args|

    config = args.shift

    c = {}
    c[:syncdev]  = config['syncdev'] if config['syncdev']
    c[:syncpeer] = config['syncpeer'] if config['syncpeer']
    c[:maxupd]   = config['maxupd'] if config['maxupd']
    c[:defer]    = config['defer'] if config['defer']

    return Hostname_if::Pfsync.new(c).content
  end
end
