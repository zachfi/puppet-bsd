require_relative '../puppet_x/bsd/ifconfig'

Facter.add('interface_groups') do
  confine kernel: [:openbsd, :freebsd]

  setcode do
    groups = {}
    output = Facter::Util::Resolution.exec('ifconfig')
    interfaces = PuppetX::BSD::Ifconfig.new(output).parse

    interfaces.each do |k, v|
      g = v.dig(:groups)
      next if g.nil?

      g.compact.each do |gr|
        groups[gr] = [] if groups[gr].nil?
        groups[gr] << k unless groups[gr].include? k
      end
    end

    groups
  end
end
