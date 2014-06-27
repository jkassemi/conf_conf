# ConfConf

Securely store, manage, and verify availability of environment variables for your
application over multiple environments.

ConfConf encrypts the configuration values it stores, and intends to allow this
configuration to contain sensitive information while living in source control.

Set a variable:

```
$ conf_conf variables set --env=development MANDRILL_SECRET=XYZ
```

Check environment consistency:

```
$ conf_conf environments check
  {
    "production":{
      "missing":[
        "MANDRILL_SECRET"
      ]
    }
  }
```

Export a .env file:

```
$ conf_conf export development > .env
  MANDRILL_SECRET=XYZ
```

Fail fast:

```
$ bundle exec rails c
fail: ConfConf::InconsistentConfigurationError
```

## Install ConfConf

```
$ gem install conf_conf
$ conf_conf --help
```

ConfConf can manage configuration variables as a standalone application, but if
you're using Ruby, ConfConf can load yoru configuration directly from the
encrypted files.

Add `gem 'conf_conf'` to your application's Gemfile and `bundle install`

Better yet, go to https://rubygems.org/gems/conf_conf and configure a specific version requirement.

## Usage

Initialize storage and key management:

```
$ conf_conf init
```

This creates the `config/conf_conf` directory, where environments are encrypted
and subsequently stored. Additionally, if ~/.conf_conf.json was not present,
init will write a keypair to the file.

## Initialize Environments

For each of the environments your application runs under, add an environment to
ConfConf:

```
$ conf_conf environments add development
$ conf_conf environments add production
$ conf_conf environments list
  [
    "development",
    "production"
  ]
```

## Load Configuration

Set up two variables that should be available for both the production and
development environments:

```
$ conf_conf variables set USE_HEADER_BLOCK=true ENABLE_JSON_RESPONSES=true
```

Check that they're in place:

```
$ conf_conf info
  {
    "environments":[
      "development",
      "production"
    ],
    "variables":{
      "USE_HEADER_BLOCK":[
        "development",
        "production"
      ],
      "ENABLE_JSON_RESPONSES":[
        "development",
        "production"
      ]
    }
  }
```

Disable JSON responses in production:

```
$ conf_conf variables set --env=production ENABLE_JSON_RESPONSES=false
```

## Importing .env

If a dotenv file (.env) exists, variables defined there can be merged into the
ConfConf container:

```
$ cat .env
  USE_FOOTER_BLOCK=true

$ conf_conf import development
  {
    "USE_HEADER_BLOCK":"true",
    "ENABLE_JSON_RESPONSES":"true",
    "USE_FOOTER_BLOCK":"true"
  }
```

## Exporting .env

The development environment:

```
$ conf_conf export development > .env
$ cat .env
  USE_HEADER_BLOCK=true
  ENABLE_JSON_RESPONSES=true
  USE_FOOTER_BLOCK=true
```

And the production environment:

```
$ conf_conf export production > .env
$ cat .env
  USE_HEADER_BLOCK=true
  ENABLE_JSON_RESPONSES=false
```

## Detecting Configuration Inconsistencies

An application running in the development environment has access to the
USE_FOOTER_BLOCK variable. When the application runs in production, it may not
have access to the proper configuration:

```
$ conf_conf environments check
  {
    "production":{
      "missing":[
        "USE_FOOTER_BLOCK"
      ]
    }
  }
```

## Multiple Developers / Keys

Additional access keys can be configured to allow access to the encrypted
configuration. Given the other developers public key from the ~/.conf_conf.json
file (or by running `conf_conf developers key`). Permit two other developers
access to the environment configurations:

```
$ conf_conf developers permit <developer-key>
$ conf_conf developers permit <developer-key2>
```

Revoke access:

```
$ conf_conf developers revoke <developer-key2>
```

Revoking a key will update all environments, and the key will no longer be able
to access any content within them. The key still had access to the values at one
point, so they should be changed promptly.

ConfConf tracks variable values that have not changed since the revokation. An
interface for viewing these variables is planned.

## Add ConfConf to your Rails/Ruby Project

You don't need an application to use ConfConf, but if you're using Ruby,
ConfConf can load your environment variables directly from the encrypted
files.

Add `gem 'conf_conf'` to your application's Gemfile and `bundle install`

Better yet, go to https://rubygems.org/gems/conf_conf and configure a specific version requirement.


## Loading Environments with Ruby

Add a new initializer and within it a ConfConf configuration block:

```ruby
# config/initializers/conf_conf.rb
environment = Rails.env
ConfConf.configuration(environment)
```

To access configuration values through a configuration object and not ENV:

```ruby
# config/initializers/conf_conf.rb
$configuration = ConfConf.configuration('production') do
  config :secret_key
end
```

In the case above, if `SECRET_KEY` is not present, `ConfConf::MissingConfigurationValueError` is raised. If it is, then $configuration.secret_key will contain the value from `ENV["SECRET_KEY"]`.

### Default Values

Pass an options hash with the `:default` key set to  a default value to prevent
the boot from raising an error when the value isn't available from the
environment. This will prevent inconsistency exceptions.

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
environment = ENV['RAILS_ENV'] # ConfConf values are merged, so this can still be part of the system's environment
ConfConf.rails_configuration(environment) do
  # Sets Rails.configuration.secret_key
  config :secret_key
end
```
