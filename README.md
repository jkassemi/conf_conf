# ConfConf


A utility for verifying the correctness of environment variables at application boot so you can fail fast when there's a configuration problem.


## Add ConfConf to your Rails/Ruby Project


Add `gem 'conf_conf'` to your application's Gemfile and `bundle install`

Better yet, go to https://rubygems.org/gems/conf_conf and configure a specific version requirement.


## Usage

Add a new initializer with your ConfConf configuration block:


```ruby
# config/initializers/conf_conf.rb
$configuration = ConfConf.configuration do
  # Sets $configuration.secret_key, app fails to boot if not present
  config :secret_key
end
```


In the case above, if SECRET_KEY is not present, then the above code raises `ConfConf::MissingConfigurationValueError` 

### Default Values

```ruby
# Sets $configuration.public_key from ENV["PUBLIC_KEY"], or uses the default if not available in ENV
config :public_key, default: "XYZ123"
```

### Casting

You can adjust the value from the environment and typecast it or perform additional validation by passing a block to `config`:

```ruby
# Sets $configuration.admin to a boolean value of true or false based on truthiness of ENV key, app fails to boot if not present
config(:admin) { |admin| 
  admin ? true : false 
}
```

### Varying Names

If you'd like to reference a configuration value with a different name, you can use the `from` key as an option to `config` and pass it the name to expect from the environment.

```ruby
# Sets $configuration.public_key from ENV["PUBLIC_KEY_WITH_ALT_NAME"]
config :public_key, from: "PUBLIC_KEY_WITH_ALT_NAME"
```

## Rails.configuration

To assign directly to Rails.configuration instead of $configuration, you can use `ConfConf.rails_configuration` method.

```ruby
# config/initializers/conf_conf.rb
ConfConf.rails_configuration do
  # Sets Rails.configuration.secret_key
  config :secret_key
end
```
