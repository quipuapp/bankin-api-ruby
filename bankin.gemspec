# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bankin/version'

Gem::Specification.new do |spec|
  spec.name          = "bankin-api-ruby"
  spec.version       = Bankin::VERSION
  spec.authors       = ["Maxim Novichenko"]
  spec.email         = ["maxim@getquipu.com"]

  spec.summary       = "Ruby client for the Bankin' API"
  spec.homepage      = "https://getquipu.com"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
