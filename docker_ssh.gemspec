$:.push File.expand_path("../lib", __FILE__)

require 'docker_ssh/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "docker-ssh"
  s.version     = DockerSSH::VERSION
  s.authors     = ["Kris Watson"]
  s.email       = ["kris@computestacks.com"]
  s.homepage    = "https://git.computestacks.com"
  s.summary     = "ComputeStacks Docker Integration"
  s.description = "ComputeStacks Docker Integration"
  s.license     = "closed-source"
  s.required_ruby_version     = '>= 1.9.3'
  s.add_dependency 'json',      "~> 1.8"
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]


end
