Facter.add('cloned_interfaces') do
  setcode do
    Facter::Util::Resolution.exec('ifconfig -C').split
  end
end
