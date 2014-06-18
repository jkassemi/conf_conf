# EnvConfig

Twelve factor applications pull configuration values from the 
environment. These variables should be verified at application
boot to prevent exceptions and unexpected behavior during
run time.

EnvConfig is a simple pattern and utility for verifying the
correctness of the environment variables at application boot so
we can fail fast when there's a configuration problem.

## Installation

Add `gem 'env_config'` to your application's Gemfile.

## Rails 

Add a new initializer - if you use env_config.rb, as a matter
of convention you shouldn't add EnvConfig configuration blocks
to other initializers.

```ruby
# config/initializers/env_config.rb
EnvConfig.rails_configuration do
  # Sets Rails.configuration.secret_key, app fails to boot if not present
  config :secret_key

  # Sets Rails.configuration.public_key from ENV["public_key"], or uses the default if not available in ENV
  config :public_key, default: "XYZ123"

  # Sets Rails.configuration.admin to a boolean value of true or false, app fails to boot if not present
  config :admin, { |admin| admin ? true : false } 
end
```

In the case above, if SECRET_KEY is not present, then
`EnvConfig::MissingConfigurationValueError` is raised:

```
  $ bin/rails s
  ...
  Exiting
  env_config/lib/env_config.rb:50:in `default_value': Please set SECRET_KEY or supply a default value
(EnvConfig::MissingConfigurationValueError)
    from env_config/lib/env_config.rb:42
    ...
```
