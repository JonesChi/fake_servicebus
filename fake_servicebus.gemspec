# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fake_servicebus/version'

Gem::Specification.new do |gem|
  gem.name          = "fake_servicebus"
  gem.version       = FakeServiceBus::VERSION
  gem.authors       = ["JonesChi"]
  gem.email         = ["duguschi@gmail.com"]
  gem.summary       = %q{Provides a fake Service Bus server that you can run locally to test against}
  gem.homepage      = "https://github.com/JonesChi/fake_servicebus"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = "MIT"


  gem.add_dependency "rack", "~> 1.6"
  gem.add_dependency "sinatra", "~> 1.4"
  gem.add_dependency "builder", "~> 3.2"
  gem.add_dependency "nokogiri", "~> 1.11.0"
  gem.add_dependency "ruby-duration", "~> 3.2"

  gem.add_development_dependency "rspec", "~> 3.6"
  gem.add_development_dependency "rake", "~> 12.0"
  gem.add_development_dependency "rack-test", "~> 0.7"
  gem.add_development_dependency "thin", "~> 1.7"
  gem.add_development_dependency "verbose_hash_fetch", "~> 0.0"
  gem.add_development_dependency "activesupport", "~> 5.1"
end
