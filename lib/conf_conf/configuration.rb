module ConfConf
  class Configuration
    attr_reader :parsed_values
    attr_reader :references

    def initialize
      @parsed_values = {}
      @references = {}
    end

    def run(block)
      instance_eval(&block)
    end

    def config(key, options={})
      reference = Reference.new(key, options)
      @references[reference.environment_key] = reference

      value = reference.value

      if block_given?
        value = yield(value)
      end

      @parsed_values[key] = value
    end
  end

  private
  class Reference < Struct.new(:key, :options)
    def value
      environment_value || default_value
    end

    def default_value?
      options[:default]
    end

    def environment_key
      options[:from] || key.to_s.upcase
    end

    private
    def default_value
      if options.has_key? :default
        options[:default]
      else
        raise ConfConf::MissingConfigurationValueError.new("Please set #{environment_key} or supply a default value")
      end
    end

    def environment_value
      ENV[environment_key]
    end

  end
end
