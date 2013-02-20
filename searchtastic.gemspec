# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "searchtastic/version"

Gem::Specification.new do |s|
  s.name        = "searchtastic"
  s.version     = Searchtastic::VERSION
  s.authors     = ["Pete Michaud"]
  s.email       = ["me@petermichaud.com"]
  s.homepage    = "http://github.com/PeteMichaud/searchtastic"
  s.summary     = "Enables ActiveRecord Model Searching"
  s.description = "Enables ActiveRecord Model Searching"
  s.rubyforge_project = "searchtastic"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["config", "lib"]

  #s.add_dependency 'activesupport', '~> 3.2'
  s.add_dependency 'chronic', '~> 0.9'

  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'rspec', '~> 2.10'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'minitest-rails', '~> 0.2'
  s.add_development_dependency 'minitest', '~> 3.0' if RUBY_PLATFORM == "java"
end