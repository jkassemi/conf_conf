require 'multi_json'
require 'ostruct'

require 'rbnacl/libsodium'
require 'rbnacl'

require 'conf_conf/project'
require 'conf_conf/configuration'
require 'conf_conf/project/developer'
require 'conf_conf/project/developers'
require 'conf_conf/project/environment'
require 'conf_conf/project/environment/storage'
require 'conf_conf/project/environments'

module ConfConf
  VERSION = '2.0.3'

  class MissingConfigurationValueError < StandardError; end;
  class InconsistentConfigurationError < StandardError
    attr_reader :inconsistencies

    def initialize(inconsistencies)
      @inconsistencies = inconsistencies
    end
  end

  class << self
    #TODO: This could be cleaned up considerably.
    def configuration(environment_name=nil, &block)
      if environment_name
        # Load ENV
        project         = ConfConf::Project.new
        environment     = project.environments[environment_name]

        environment.variables.each do |name, value|
          ENV[name] = value
        end
      end

      # Run configuration block, if given
      configuration = ConfConf::Configuration.new

      if block
        configuration.run(block)
        references      = configuration.references
      else
        references      = {}
      end

      if environment_name
        # Find references to variables that aren't defaulted here
        inconsistencies = project.inconsistencies(environment)

        inconsistencies.each do |inconsistency|
          if references[inconsistency] && references[inconsistency].default_value?
            inconsistencies.delete(inconsistency)
          end
        end

        if inconsistencies.length > 0
          raise ConfConf::InconsistentConfigurationError.new(inconsistencies)
        end
      end

      OpenStruct.new(configuration.parsed_values)
    end

    def rails_configuration(environment_name=nil, &block)
      configuration = configuration(environment_name, block)

      configuration.parsed_values.each do |name, value|
        Rails.configuration.send("#{key}=", value)
      end
    end

    def load(environment_name)
      configuration(environment_name)
    end
  end
end
