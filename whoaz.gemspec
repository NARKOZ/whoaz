# -*- encoding: utf-8 -*-
require File.expand_path('../lib/whoaz/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Nihad Abbasov"]
  gem.email         = ["nihad@42na.in"]
  gem.description   = %q{A gem that provides a nice way to interact with Whois.Az}
  gem.summary       = %q{Gets domain whois information from Whois.Az}
  gem.homepage      = "https://narkoz.github.io/whoaz"
  gem.license       = "BSD"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "whoaz"
  gem.require_paths = ["lib"]
  gem.version       = Whoaz::VERSION

  gem.required_ruby_version = ">= 2.0.0"

  gem.add_runtime_dependency 'nokogiri'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'fakeweb'
end
