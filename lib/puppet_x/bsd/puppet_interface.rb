require_relative '../../puppet_x/bsd'

# A base class that handles some of the necessary validation common among the
# PuppetX::BSD code that interfaces with the values received from Puppet
# functions.  This allows for simple(r) construcuts within the child classes
# that use this class to configure which configuration values are required, and
# which are optional, as well as which are multi-valued arrays.
#
class PuppetX::BSD::PuppetInterface
  attr_reader :config

  def configure(config)
    raise ArgumentError, 'Config object must be a Hash' unless config.is_a? Hash

    # Set the empty configuration items unless they've been set using the
    # optsions, validation, or multiopts methods in the child classes.
    @config_options = [] unless @config_options

    @config_validation = [] unless @config_validation

    @config_multiopts = [] unless @config_multiopts

    @config_oneof = [] unless @config_oneof

    @config_validation_exclusive = [] unless @config_validation_exclusive

    @config_booleans = [] unless @config_booleans

    @config_integers = [] unless @config_integers

    @config = validate(reject_undef(config))
  end

  def reject_undef(obj)
    if obj.is_a? Array
      obj.reject do |_k, _v|
        (i == :nil) || (i == :undef)
      end
    elsif obj.is_a? Hash
      obj.reject do |k, v|
        (k == :undef) || (v == :undef) ||
          (k == :nil) || (v == :nil)
      end
    else
      obj
    end
  end

  def options(*options_array)
    # an array of options available
    unless options_array.is_a? Array
      raise ArgumentError, 'Array of options required'
    end

    @config_options = options_array
  end

  def validation(*required_array)
    # an array of required items to validate
    unless required_array.is_a? Array
      raise ArgumentError, 'Array of names to validate required'
    end

    @config_validation = required_array
  end

  def multiopts(*multi_values_options_array)
    unless multi_values_options_array.is_a? Array
      raise ArgumentError, 'Array required for multiopts'
    end

    @config_multiopts = multi_values_options_array
  end

  def oneof(*require_oneof_array)
    unless require_oneof_array.is_a? Array
      raise ArgumentError, 'Array of names to validate required'
    end

    @config_oneof = require_oneof_array
  end

  def exclusive(*require_exclusive_array)
    unless require_exclusive_array.is_a? Array
      raise ArgumentError, 'Array of exclusive names to validate required'
    end

    @config_validation_exclusive = require_exclusive_array
  end

  def booleans(*boolean_options)
    unless boolean_options.is_a? Array
      raise ArgumentError, 'Array required for boolean options'
    end

    @config_booleans = boolean_options
  end

  def integers(*integer_options)
    unless integer_options.is_a? Array
      raise ArgumentError, 'Array required for integer options'
    end

    @config_integers = integer_options
  end

  def validate(config)
    # Check requirements for all options

    if @config_validation
      @config_validation.each do |k, _v|
        unless config.keys.include? k
          raise ArgumentError, "required configuration item not found: #{k}"
        end
      end
    end

    # Check for unknown configuration items
    if @config_validation && @config_options
      config.each do |k, _v|
        unless @config_validation.include?(k) || @config_options.include?(k)
          raise ArgumentError, "unknown configuration item found: #{k}"
        end
      end

    elsif @config_validation
      config.each do |k, _v|
        unless @config_validation.include? k
          raise ArgumentError, "unknown configuration item found: #{k}"
        end
      end

    elsif @config_options
      config.each do |k, _v|
        unless @config_options.include? k
          raise ArgumentError, "unknown configuration item found: #{k}"
        end
      end
    end

    # Check the values of multiopts to ensure list
    @config_multiopts.each do |i|
      next unless config.keys.include? i
      unless config[i].is_a? Array
        raise ArgumentError, "Multi-opt #{i} is not an array"
      end
    end

    @config_booleans.each do |i|
      next unless config.keys.include? i
      unless (config[i].class == true.class) || (config[i].class == false.class)
        raise ArgumentError, "Boolean-opt #{i} is not a bool"
      end
    end

    @config_integers.each do |i|
      next unless config.keys.include? i
      unless config[i].is_a? Integer
        raise ArgumentError, "Integer-option #{i} must be an Integer, is: #{i.class}"
      end
    end

    # Config values not in multopts should be a string
    config.each do |k, v|
      next if @config_multiopts.include? k
      next if @config_booleans.include? k
      next if @config_integers.include? k

      unless v.is_a? String
        raise ArgumentError, "Config option #{k} must be a String"
      end
    end

    # Check exclusive options don't conflict
    if @config_validation_exclusive && !@config_validation_exclusive.empty?
      exclusive_items = @config_validation_exclusive.select { |k| config.keys.include? k }
      unless exclusive_items.size == 1
        raise ArgumentError, "One and only one of #{@config_validation_exclusive} may be used at a time"
      end
    end
    # Check that at least one oneof config items are present
    if @config_oneof && !@config_oneof.empty?
      oneof_items = config.keys.select { |k| @config_oneof.include? k }
      unless oneof_items.size >= 1
        raise ArgumentError, "At least one of #{@config_oneof} is required"
      end
    end

    config
  end
end
