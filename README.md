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
  config :secret_key
end
```

In the case above, if `SECRET_KEY` is not present, `ConfConf::MissingConfigurationValueError` is raised. If it is, then $configuration.secret_key will contain the value from `ENV["SECRET_KEY"]`.

### Default Values

Pass an options hash with the `:default` key set to the value you'd like if you
don't want the boot to raise an error when the value isn't available from the
ENV.

```ruby
config :public_key, default: "XYZ123"
```

### Casting

You can adjust the value from the environment and typecast it or perform additional validation by passing a block to `config`:

```ruby
config(:admin) { |admin| 
  admin ? true : false 
}
```

### Varying Names

If you'd like to reference a configuration value with a different name, you can use the `:from` key as an option to `config` and pass it the name to expect from the environment.

```ruby
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
