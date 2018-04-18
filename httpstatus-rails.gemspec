$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "httpstatus/rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'httpstatus-rails'
  s.version     = Httpstatus::Rails::VERSION
  s.authors     = ['Julien Dargelos']
  s.email       = ['contact@juliendargelos.com']
  s.homepage    = 'https://www.github.com/juliendargelos/httpstatus-rails'
  s.summary     = 'Makes http status rendering cool.'
  s.description = 'This gem provides a minimal and customizable rendering content for every status and format included in Rails.'
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.1.6"

  s.add_development_dependency "sqlite3"
end
