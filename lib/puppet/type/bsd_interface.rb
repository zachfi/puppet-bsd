Puppet::Type.newtype(:bsd_interface) do
  @doc = "Manage a network interface state on BSD"

  newparam :name, :namevar => true

  ensurable do
    desc("The state the interface should be in.")

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end

    newvalue(:up) do
      provider.up
    end

    newvalue(:down) do
      provider.down
    end

    aliasvalue(:down, :absent)
    aliasvalue(:up, :present)

    defaultto :present
  end

  newproperty(:state) do
    newvalue(:up)
    newvalue(:down)
    newvalue(:absent)
  end
end
