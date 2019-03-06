require 'spec_helper'
require 'puppet_x/bsd/puppet_interface'

describe 'PuppetX::BSD::PuppetInterface' do
  let(:demo_class) do
    class DemoClass < PuppetX::BSD::PuppetInterface
      super
      options :one, :two, :three
      validation :name
    end
  end

  context 'configure' do
    it 'fails validation when an array is received' do
      c = PuppetX::BSD::PuppetInterface.new

      expect { c.configure([]) }.to raise_error(ArgumentError, %r{must be a Hash})
    end

    it 'does not fail when no options or validation is passed' do
      c = PuppetX::BSD::PuppetInterface.new

      expect { c.configure({}) }.not_to raise_error
    end

    context 'when options are available' do
      it 'returns a boring yet valid config' do
        c = PuppetX::BSD::PuppetInterface.new
        c.options :one, :two, :three

        expect { c.configure({}) }.not_to raise_error
      end
    end

    context 'when validation is required but not present' do
      it 'fails with an ArgumentError' do
        c = PuppetX::BSD::PuppetInterface.new
        c.validation :one, :two, :three

        expect { c.configure({}) }.to raise_error(ArgumentError, %r{required configuration item not found})
      end
    end

    context 'when validation is required and present' do
      it 'configures successfully' do
        c = PuppetX::BSD::PuppetInterface.new
        c.validation :one, :two, :three

        wanted = {
          one: 'itemone',
          two: 'itemtwo',
          three: 'itemthree'
        }

        expect { c.configure(wanted) }.not_to raise_error
        expect(c.config).to eq(wanted)
      end
    end

    context 'when validation is required and present with options' do
      it 'configures successfully with no options passed' do
        c = PuppetX::BSD::PuppetInterface.new
        c.validation :one, :two, :three
        c.options :four, :five

        config = {
          one: 'itemone',
          two: 'itemtwo',
          three: 'itemthree'
        }

        expect { c.configure(config) }.not_to raise_error
        expect(c.config).to eq(config)
      end

      it 'includes options in the config when options are passed' do
        c = PuppetX::BSD::PuppetInterface.new
        c.validation :one, :two, :three
        c.options :four, :five

        config = {
          one: 'itemone',
          two: 'itemtwo',
          three: 'itemthree',
          five: 'itemfive'
        }

        expect { c.configure(config) }.not_to raise_error
        expect(c.config).to eq(config)
      end
    end

    context 'when mutliopts is set' do
      it 'fails when option values are not an array' do
        c = PuppetX::BSD::PuppetInterface.new
        c.options :one, :two
        c.multiopts :one

        config = {
          one: 'string'
        }
        expect { c.configure(config) }.to raise_error(ArgumentError, %r{Multi-opt one is not an array})
      end

      it 'configures when option values are an array' do
        c = PuppetX::BSD::PuppetInterface.new
        c.options :one, :two
        c.multiopts :one

        config = {
          one: %w[string stringagain]
        }
        expect { c.configure(config) }.not_to raise_error
      end
    end

    context 'oneof' do
      it 'fails when oneof config values are not present' do
        c = PuppetX::BSD::PuppetInterface.new
        c.options :one, :two, :three
        c.oneof :one, :two

        config = {}
        expect { c.configure(config) }.to raise_error(ArgumentError, %r{At least one of.*is required})
      end

      it 'configures when one oneof config value is present' do
        c = PuppetX::BSD::PuppetInterface.new
        c.options :one, :two, :three
        c.oneof :one, :two

        config = {
          one: 'string'
        }
        expect { c.configure(config) }.not_to raise_error
      end
    end
  end
end
