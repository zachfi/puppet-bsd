require 'spec_helper'
#require 'puppet/provider/bsd_interface/ifconfig'

type_class = Puppet::Type.type(:bsd_interface)

describe type_class do

  [:absent, :present].each do |v|
    it "should support #{v} as a value to :ensure" do
      em = type_class.new(:name => 'em0', :ensure => v)
      expect(em.should(:ensure)).to eq(v)
    end
  end

  it "should alias :up to :present as a value to :ensure" do
    em = type_class.new(:name => 'em0', :ensure => :up)
    expect(em.should(:ensure)).to eq(:present)
  end

  it "should alias :down to :absent as a value to :ensure" do
    em = type_class.new(:name => 'em0', :ensure => :down)
    expect(em.should(:ensure)).to eq(:absent)
  end
end
