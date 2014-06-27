class ConfConf::CLI::Variables < Thor
  desc 'set', 'Set configuration values in the given environment'
  option :env, default: false, desc: 'environment to set the config var'
  long_desc <<-LONG
    Sets Config Values in the given Environment.

    Examples:

    > $ conf_conf set X=1

    Sets the Config Key `X` with Config Value `1` for all Environments.

    > $ conf_conf set --env=production X=1

    Sets the Config Key `X` with Config Value `1` for `production` Environment.
    Sets the Config Key `X` with the Config Value `1` for the
    `production` Environment.

    > $ conf_conf set --env=production X=1 Y=2 Z=3

    Sets the Config Keys `X`, `Y`, and `Z` with the Config
    Values `1`, `2`, and `3`, respectively. Config Values are saved to
    the `production` Environment.
  LONG
  def set(*env_variable_args)
    project      = ConfConf::Project.new
    developers   = project.developers

    developer = ConfConf::Project::Developer.current
    developers.add(developer)

    if options[:env]
      environments = [project.environments[options[:env]]]
    else
      environments = project.environments.to_a
    end

    return if environments.length == 0

    env_variable_args.each do |env_variable|
      config_key, config_value = env_variable.split("=").map(&:strip)

      environments.each do |environment|
        environment.set(config_key, config_value)
      end
    end

    environments.map(&:save)
  end

  desc 'remove', 'Remove a configuration value'
  option :env, default: 'development', desc: 'environment to remove the config var from'
  long_desc <<-LONG
    Examples:

    > $ conf_conf remove X

    Removes the `X` Environment Variable

    > $ conf_conf remove --env=production X

    Removes `X` from production only
  LONG
  def remove(*name_args)
    project      = ConfConf::Project.new

    all_environments = project.environments.to_a

    if options[:env]
      environments = [project.environments[options[:env]]]
    else
      environments = all_environments
    end

    return if environments.length == 0

    name_args.each do |name|
      environments.each do |environment|
        environment.remove(name)
      end
    end

    environments.map(&:save)
  end
end
