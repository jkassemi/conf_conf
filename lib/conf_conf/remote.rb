module ConfConf
  ## Interfaces with the conf_conf.io system
  module Remote
    SAVE_ENVIRONMENT_URL = "https://api.conf_conf.io/save"
    LOAD_ENVIRONMENT_URL = "https://api.conf_conf.io/load" 

    def self.save_environment(environment)
      request = HTTPI::Request.new
      request.url = SAVE_ENVIRONMENT_URL
      request.body = { 
                        project:  environment.project, 
                        name:     environment.name, 
                        encrypted_env_variables:  environment.encrypted_env_variables 
                     }

      response = HTTPI.post(request)

      raise ConfConf::Remote::SaveException.new(response.body) if response.error?
    end

    def self.load_environment(project, name)
      request = HTTPI::Request.new
      request.url = LOAD_ENVIRONMENT_URL
      request.body = { 
                       project: project,
                       name: name
                     }

      response = HTTPI.post(request)

      raise ConfConf::Remote::LoadException.new(response.body) if response.error?

      parsed_response = MultiJson.load(response.body) 

      environment = Environment.new(parsed_response.project, parsed_response.name)
      environment.encrypted_env_variables = parsed_response.encrypted_env_variables
      environment
    end
  end
end
