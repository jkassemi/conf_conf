# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name             = "conf_conf"
  s.version          = "1.0.2"
  s.licenses         = ["MIT"]
  s.authors          = ["James Kassemi"]
  s.email            = ["jkassemi@gmail.com"]
  s.homepage         = "https://github.com/jkassemi/conf_conf"
  s.description      = "Verify correctness of environment variables"
  s.summary          = "A simple pattern and utility for verifying the correctness of the environment variables at application boot so we can fail fast when there's a configuration problem."
  s.files            = `git ls-files`.split($/)

  s.add_development_dependency 'rspec', '~> 3.0'
end
