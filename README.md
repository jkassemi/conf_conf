# ConfConf

ConfConf is a pattern and utility for verifying the
correctness of the environment variables at application boot so
you can fail fast when there's a configuration problem.

## Installation

Add `gem 'conf_conf'` to your application's Gemfile.

## Usage

Add a new initializer - if you use conf_conf.rb , as a matter of 
convention you shouldn't add ConfConf configuration blocks to
other initializers.

```ruby
# config/initializers/conf_conf.rb
$configuration = ConfConf.configuration do
  # Sets $configuration.secret_key, app fails to boot if not present
  config :secret_key
end
```

In the case above, if SECRET_KEY is not present, then
`ConfConf::MissingConfigurationValueError` is raised:

```
  $ bin/rails s
  ...
  Exiting
  conf_conf/lib/conf_conf.rb:50:in `default_value': Please set SECRET_KEY or supply a default value
(ConfConf::MissingConfigurationValueError)
    from conf_conf/lib/conf_conf.rb:42
    ...
```

### Default Values

```ruby
# Sets $configuration.public_key from ENV["PUBLIC_KEY"], or uses the default if not available in ENV
config :public_key, default: "XYZ123"
```

### Casting

You can adjust the value from the environment and typecast it or perform
additional validation by passing a block to `config`:

```ruby
# Sets $configuration.admin to a boolean value of true or false based on truthiness of ENV key, app fails to boot if not present
config(:admin) { |admin| 
  admin ? true : false 
}
```

### Varying Names

If you'd like to reference a configuration value with a different name, you can
use the `from` key as an option to `config` and pass it the name to expect from
the environment.

```ruby
# Sets $configuration.public_key from ENV["PUBLIC_KEY_WITH_ALT_NAME"]
config :public_key, from: "PUBLIC_KEY_WITH_ALT_NAME"
```

## Rails.configuration

To assign directly to Rails.configuration instead of CONFCONF, you can
use `ConfConf.rails_configuration` method.

```ruby
# config/initializers/conf_conf.rb
ConfConf.rails_configuration do
  # Sets Rails.configuration.secret_key
  config :secret_key
end
```
