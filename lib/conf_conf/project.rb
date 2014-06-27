module ConfConf
  class Project
    attr_reader :developers, :environments

    def initialize
      @developers   = Developers.load(self)
      @environments = Environments.new(self)
    end

    def inconsistencies(environment)
      all_environment_variable_names = Set.new

      environments.to_a.each do |other_environment|
        all_environment_variable_names += other_environment.variables.keys
      end

      all_environment_variable_names - environment.variables.keys
    end
  end
end
