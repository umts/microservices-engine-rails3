# frozen_string_literal: true
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'microservices_engine/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'umts-microservices-engine'
  s.version     = MicroservicesEngine::VERSION
  s.authors     = ['UMass Transportation Services']
  s.email       = ['transit-it@admin.umass.edu']
  s.homepage    = 'https://github.com/umts/microservices-engine'
  s.summary     = 'Simple UMTS inter-service communication network'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.rdoc']
  s.require_path = 'lib'

  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '~> 3.0'

  s.add_development_dependency 'rspec-rails', '~> 3.5'
  s.add_development_dependency 'webmock', '~> 2.1'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'simplecov', '~> 0.12'
  s.add_development_dependency 'sqlite3', '~> 1.3'
end
