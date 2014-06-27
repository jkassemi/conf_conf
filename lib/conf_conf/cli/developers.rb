class ConfConf::CLI::Developers < Thor
  desc 'key', 'Your developer key'
  def key
    developer = ConfConf::Project::Developer.current

    puts MultiJson.dump(developer.pretty_public_key, pretty: true)
  end

  desc 'permit <key>', 'Give <key> access to environment configurations'
  def permit(key)
    project    = ConfConf::Project.new
    developer  = ConfConf::Project::Developer.new(key)
    developers = project.developers

    developers.add(developer)
    developers.save

    project.environments.to_a.each do |environment|
      environment.save
    end

    puts MultiJson.dump(developers.keys.to_a, pretty: true)
  end

  desc 'revoke <key>', 'Deny <key> access to the environment configurations'
  def revoke(key)
    project    = ConfConf::Project.new
    developer  = ConfConf::Project::Developer.new(key)
    developers = project.developers

    developers.remove(developer)
    developers.save

    project.environments.to_a.each do |environment|
      environment.save
    end

    puts MultiJson.dump(developers.keys.to_a, pretty: true)
  end

  desc 'list', 'List of keys with access to the environment configurations'
  def list
    project    = ConfConf::Project.new
    developers = project.developers

    puts MultiJson.dump(developers.keys.to_a, pretty: true)
  end
end
