module Validation
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
  end

  module ClassMethods
    attr_reader :validation_rules

    def validate(name, options = {})
      @validation_rules ||= []
      options.each do |type, args|
        @validation_rules << { name: name, type: type, args: args } if options[type]
      end
    end
  end

  module InstanceMethods
    def valid?
      return true if self.class.validation_rules.nil?

      self.class.validation_rules.all? do |rule|
        value = send(rule[:name])
        send "validate_#{rule[:type]}", value, rule[:args]
      end
    end

    def validate!
      return true if self.class.validation_rules.nil?

      self.class.validation_rules.each do |rule|
        value = send(rule[:name])
        raise "#{rule[:name]} failed #{rule[:type]} validation" unless send "validate_#{rule[:type]}", value, rule[:args]
      end
    end

    protected

    def validate_presence(value, _)
      value.nil? || value == '' ? false : true
    end

    def validate_format(value, pattern)
      pattern.match?(value)
    end

    def validate_type(value, type)
      value.is_a?(type)
    end
  end
end
