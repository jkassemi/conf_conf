require 'ostruct'

Dir["tasks/**/*.rake"].each { |ext| load ext } if defined?(Rake)

module ConfConf
  class MissingConfigurationValueError < StandardError; end;

  class << self
    def configuration(&block)
      OpenStruct.new(Configuration.new(&block).parsed_values)
    end

    def rails_configuration(&block)
      configuration = Configuration.new
      configuration.run(block)

      configuration.parsed_values.each do |key, value|
        Rails.configuration.send("#{key}=", value)
      end
    end
  end

  class Configuration
    attr_reader :parsed_values

    def initialize(&block)
      @parsed_values = {}
      run(block) if block
    end

    def run(block)
      instance_eval(&block)
    end

    def config(key, options={})
      value = Reference.new(key, options).value

      if block_given?
        value = yield(value)
      end

      @parsed_values[key] = value
    end
  end

  class Reference < Struct.new(:key, :options)
    def value
      environment_value || default_value
    end 

    private
    def default_value
      if options.has_key? :default
        options[:default]
      else
        raise MissingConfigurationValueError.new("Please set #{environment_key} or supply a default value")
      end
    end

    def environment_value
      ENV[environment_key]
    end

    def environment_key
      options[:from] || key.to_s.upcase
    end
  end
end
