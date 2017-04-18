# Module: PuppetX::Hostname_if::Pfsync
#
# Responsible for processing the pfsync(4) interfaces for hostname_if(5)
#
require_relative '../../../puppet_x/bsd/hostname_if'
require_relative '../../../puppet_x/bsd/puppet_interface'

class Hostname_if::Pfsync < PuppetX::BSD::PuppetInterface
  attr_reader :content

  def initialize(config)
    options :syncdev,
            :syncpeer,
            :maxupd,
            :defer

    booleans :defer

    configure(config)
  end

  def values
    data = []
    data << pfsync_string
    data.flatten
  end

  def content
    values.join("\n")
  end

  def pfsync_string
    pfsyncstring = []
    if @config[:syncdev]
      pfsyncstring << 'syncdev' << @config[:syncdev]
    else
      pfsyncstring << '-syncdev'
    end

    if @config[:syncpeer]
      pfsyncstring << 'syncpeer' << @config[:syncpeer]
    else
      pfsyncstring << '-syncpeer'
    end

    if @config[:maxupd]
      if @config[:maxupd].to_i < 0 || @config[:maxupd].to_i > 255
        raise ArgumentError, 'value of maxupd has to be in the range of 0 and 255'
      end
      pfsyncstring << 'maxupd' << @config[:maxupd]
    else
      pfsyncstring << 'maxupd' << '128'
    end

    pfsyncstring << if @config[:defer] == true
                      'defer'
                    else
                      '-defer'
                    end

    pfsyncstring.join(' ')
  end
end
