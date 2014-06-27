module ConfConf
  class Project
    class Environment < Struct.new(:project, :name, :variables, :schema)
      class << self
        def load(project, name)
          ConfConf::Project::Environment::Storage.load_project_environment(project, name)
        end
      end

      def initialize(*args)
        super
        self.variables  ||= {}
        self.schema     ||= {}
      end

      def get(variable_name)
        variable_name = normalized_variable_name(variable_name)
        variables[variable_name]
      end

      def set(variable_name, variable_value)
        variable_name = normalized_variable_name(variable_name)

        if variables[variable_name] != variable_value
          schema.delete variable_name
        end

        if schema[variable_name] && schema[variable_name]['access']
          schema[variable_name]['access'] = (project.developers.keys + schema[variable_name]['access']).to_a
        else
          schema[variable_name] = { 'access' => project.developers.keys.to_a }
        end

        variables[variable_name] = variable_value
      end

      def remove(variable_name)
        variable_name = normalized_variable_name(variable_name)
        schema.delete variable_name
        variables.delete variable_name
      end

      def save
        ConfConf::Project::Environment::Storage.save_project_environment(project, self)
      end

      private
      def normalized_variable_name(variable_name)
        variable_name.strip.upcase
      end
    end
  end
end
