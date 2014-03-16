$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "raven/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "raven"
  s.version     = Raven::VERSION
  s.authors     = ["Moneer Bandy"]
  s.email       = ["mbcomm@gmail.com"]
  s.homepage    = "https://github.com/barhum/raven"
  s.summary     = "Rails Raven API Integration"
  s.description = "More info here http://docs.pacnetservices.com/raven/"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.2"

  s.add_development_dependency "sqlite3"
end

