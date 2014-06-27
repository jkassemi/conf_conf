module ConfConf
  module CLI
    class Root < Thor
      desc 'environments', 'Manage available environments'
      subcommand 'environments', ConfConf::CLI::Environments

      desc 'variables', 'Configure environment variables'
      subcommand 'variables', ConfConf::CLI::Variables

      desc 'developers', 'Configure access credentials'
      subcommand 'developers', ConfConf::CLI::Developers

      desc 'init', 'Initialize conf_conf project'
      long_desc <<-LONG
        > $ conf_conf init

        Initialize this system user's ~/.conf_conf.json
      LONG
      def init
        account = ConfConf::Project::Developer.current
        FileUtils.mkdir_p('config/conf_conf')
        FileUtils.mkdir_p('config/conf_conf/environments')
        puts MultiJson.dump(account: account, pretty: true)
      end

      desc 'export <environment>', '.env compatible export for <environment>'
      def export(environment_name)
        project     = ConfConf::Project.new
        environment = project.environments[environment_name]

        environment.variables.each do |variable_name, variable_value|
          puts "#{variable_name}=#{variable_value}"
        end
      end

      desc 'import <environment>', 'Import from .env into <environment>'
      option :dotenv, default: true
      def import(environment_name)
        require 'dotenv'

        project = ConfConf::Project.new
        environment = project.environments[environment_name]
        dotenv_environment = Dotenv::Environment.new('.env')

        dotenv_environment.each do |k,v|
          environment.set(k, v)
        end

        environment.save
        puts MultiJson.dump(environment.variables, pretty: true)
      end

      desc 'info', 'Summary of configurations'
      def info
        project = ConfConf::Project.new

        summary = {}
        summary[:environments] = project.environments.to_a.collect(&:name)
        summary[:variables] = {}

        project.environments.to_a.each do |environment|
          environment.variables.each do |variable_name, variable_value|
            summary[:variables][variable_name] ||= []
            summary[:variables][variable_name] << environment.name
          end
        end

        puts MultiJson.dump(summary, pretty: true)
      end
    end
  end
end
