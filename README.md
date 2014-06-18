# EnvConfig

Twelve factor applications pull configuration values from the 
environment - EnvConfig helps pull those settings from the environment
when the application boots so we fail fast when they're not present
or there's a configuration problem.

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
