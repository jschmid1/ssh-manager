# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ssh/manager/version'

Gem::Specification.new do |spec|
  spec.name          = "ssh-manager"
  spec.version       = SSH::Manager::VERSION
  spec.authors       = ["Joshua Schmid, Juraj Hura"]
  spec.email         = ["jschmid@suse.com, jhura@suse.cz"]
  spec.description   = %q{ssh connections easy}
  spec.summary       = %q{manage and connect}
  spec.homepage      = "https://rubygems.org/profiles/jschmid"
  spec.license       = "GPL"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_runtime_dependency 'sequel', '=4.13.0'
  spec.add_runtime_dependency 'sqlite3', '=1.3.9'
  spec.add_development_dependency "rake"
end
