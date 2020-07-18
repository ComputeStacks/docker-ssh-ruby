lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

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
  s.required_ruby_version = '>= 2.5.0'
  s.add_dependency 'json', '~> 2.2'
  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if s.respond_to?(:metadata)
    s.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end
  s.metadata['github_repo'] = "ssh://github.com/ComputeStacks/docker-ssh-ruby.git"

end
