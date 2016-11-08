# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ood_job/version'

Gem::Specification.new do |spec|
  spec.name          = "ood_job"
  spec.version       = OodJob::VERSION
  spec.authors       = ["Jeremy Nicklas"]
  spec.email         = ["jnicklas@osc.edu"]
  spec.summary       = %q{Library that provides a generic interface to resource managers.}
  spec.description   = %q{Library that provides a generic interface to submit/status/hold/release/delete batch jobs for various resource managers.}
  spec.homepage      = "https://github.com/OSC/ood_job"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.2.0"

  spec.add_dependency "ood_cluster", "~> 0.0.1"
  spec.add_dependency "pbs", "~> 2.0", ">= 2.0.3"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.10"
end
