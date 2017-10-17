Facter.add('cloned_interfaces') do
  confine kernel: [:openbsd, :freebsd]

  setcode do
    Facter::Util::Resolution.exec('ifconfig -C').split
  end
end
