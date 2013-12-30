# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "conglomerate/version"

Gem::Specification.new do |spec|
  spec.name          = "conglomerate"
  spec.version       = Conglomerate::VERSION
  spec.authors       = ["Shane Emmons"]
  spec.email         = ["oss@teamsnap.com"]
  spec.summary       = "A library to serialize Ruby objects into collection+json"
  spec.description   = "A library to serialize Ruby objects into collection+json"
  spec.homepage      = "https://github.com/teamsnap/conglomerate"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0.beta1"
end
