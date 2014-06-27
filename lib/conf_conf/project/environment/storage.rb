module ConfConf
  class Project
    class Environment
      class NotAuthorizedError < StandardError; end;

      class Storage
        def self.load_project_environment(project, environment_name)
          current_developer = ConfConf::Project::Developer.current
          environment_config_file_path = File.join('config', 'conf_conf', 'environments', "#{environment_name}.json")

          if File.exists?(environment_config_file_path)
            environment_config       = MultiJson.load(File.read(environment_config_file_path))
            environment_schema       = environment_config['schema']
            author_public_key        = Base64.decode64(environment_config['author_public_key'])
            encrypted_environment_secret_key   = environment_config['encrypted_environment_secret_key'][current_developer.pretty_public_key]

            raise NotAuthorizedError if encrypted_environment_secret_key.nil?

            box = RbNaCl::SimpleBox.from_keypair(author_public_key, current_developer.private_key)
            environment_secret_key = box.decrypt(encrypted_environment_secret_key)

            box = RbNaCl::SimpleBox.from_secret_key(environment_secret_key)
            decrypted_environment_variables_json = box.decrypt(environment_config["encrypted_environment"])

            environment_variables = MultiJson.load(decrypted_environment_variables_json)
          else
            environment_variables = {}
            environment_schema = {}
          end

          Environment.new(project, environment_name, environment_variables, environment_schema)
        end

        def self.save_project_environment(project, environment)
          author = ConfConf::Project::Developer.current

          environment_config = {}
          environment_config[:author_public_key] = author.pretty_public_key
          environment_config[:schema] = environment.schema

          environment_secret_key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
          project.developers.add(author)

          environment_config[:encrypted_environment_secret_key] = project.developers.to_a.inject({}) do |keys,developer|
            box = RbNaCl::SimpleBox.from_keypair(developer.public_key, author.private_key)
            keys[developer.pretty_public_key] = box.encrypt(environment_secret_key); keys
          end

          box = RbNaCl::SimpleBox.from_secret_key(environment_secret_key)
          environment_config[:encrypted_environment] = box.encrypt(MultiJson.dump(environment.variables))

          environment_config_file_path = File.join('config', 'conf_conf', 'environments', "#{environment.name}.json")
          File.write(environment_config_file_path, MultiJson.dump(environment_config))
        end
      end
    end
  end
end
