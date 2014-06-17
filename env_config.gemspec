# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name             = "env-config"
  spec.version          = "1.0.0"
  spec.authors          = ["James Kassemi"] 
  spec.email            = ["jkassemi@gmail.com"]
  spec.description      = "ENV settings management"
  spec.summary          = "Require settings from ENV"
  spec.files            = `git ls-files`.split($/)

  spec.add_development_dependency 'rspec', '~> 3.0.0'
end
