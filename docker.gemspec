$:.push File.expand_path("../lib", __FILE__)

require 'docker/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "docker"
  s.version     = Docker::VERSION
  s.authors     = ["Kris Watson"]
  s.email       = ["kris@computestacks.com"]
  s.homepage    = "https://git.computestacks.com"
  s.summary     = "ComputeStacks Docker Integration"
  s.description = "ComputeStacks Docker Integration"
  s.license     = "MIT"
  s.required_ruby_version     = '>= 1.9.3'
  s.add_dependency 'json',      "~> 1.8"
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]


  #s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  #s.add_dependency "rails", "~> 4.2.5.1"


  # s.add_development_dependency "sqlite3"
end
