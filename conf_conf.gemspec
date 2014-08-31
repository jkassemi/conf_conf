# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = 'conf_conf'
  s.version     = '2.0.3'
  s.licenses    = ['MIT']
  s.authors     = ['James Kassemi']
  s.email       = ['jkassemi@gmail.com']
  s.homepage    = 'https://github.com/jkassemi/conf_conf'
  s.description = 'Verify correctness of environment variables'
  s.summary     = 'A simple pattern and utility for verifying the correctness of the environment variables at application boot so we can fail fast when there\'s a configuration problem.'
  s.files       = `git ls-files`.split($/)
  s.executables = ['conf_conf']

  s.add_runtime_dependency 'httpi',             '~> 2.2.4'
  s.add_runtime_dependency 'thor',              '~> 0.19.1'
  s.add_runtime_dependency 'colorize',          '~> 0.7.3'
  s.add_runtime_dependency 'highline',          '~> 1.6.21'
  s.add_runtime_dependency 'rbnacl-libsodium',  '~> 0.5.0.1'
  s.add_runtime_dependency 'multi_json',        '~> 1.10.1'
  s.add_runtime_dependency 'dotenv',            '~> 0.11.1'
  s.add_development_dependency 'rspec',  '~> 3.0'
end
