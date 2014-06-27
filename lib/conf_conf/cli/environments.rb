module ConfConf::CLI
  class Environments < Thor
    desc 'list', 'Show environments'
    def list
      project = ConfConf::Project.new
      puts MultiJson.dump(project.environments.to_a.collect(&:name), pretty: true)
    end

    desc 'add <environment>', 'Set up new environment'
    long_desc <<-LONG
      > $ conf_conf env add staging
    LONG
    def add(environment_name)
      project = ConfConf::Project.new
      environment = project.environments[environment_name]
      environment.save

      puts MultiJson.dump(project.environments.to_a.collect(&:name), pretty: true)
    end

    desc 'remove <environment>', 'Removes an existing environment'
    def remove(environment_name)
      project = ConfConf::Project.new
      project.environments.remove(environment_name)

      puts MultiJson.dump(project.environments.to_a.collect(&:name), pretty: true)
    end

    desc 'check (<environment>)', 'Check environment consistency'
    def check(environment_name=nil)
      project = ConfConf::Project.new

      all_environment_variable_names = Set.new

      project.environments.to_a.each do |environment|
        all_environment_variable_names += environment.variables.keys
      end

      if environment_name.nil?
        environments = project.environments.to_a
      else
        environments = [project.environments[environment_name]]
      end

      environment_warnings = {}

      environments.each do |environment|
        diff = all_environment_variable_names - environment.variables.keys

        if diff.length > 0
          diff.each do |key|
            environment_warnings[environment.name] ||= {:missing => []}
            environment_warnings[environment.name][:missing] << key
          end
        end
      end

      puts MultiJson.dump(environment_warnings, pretty: true)
    end
  end
end
