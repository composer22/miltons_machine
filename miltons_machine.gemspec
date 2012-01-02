# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "miltons_machine/version"

Gem::Specification.new do |s|
  s.rubyforge_project = "miltons_machine"
  s.name              = 'miltons_machine'
  s.version           =  MiltonsMachine::VERSION.dup
  s.required_ruby_version = '>= 1.9.3'
  s.platform          =  Gem::Platform::RUBY
  s.homepage          = 'http://github.com/composer22/miltons_machine'
  s.summary           = "Some analysis and 'practical' set theory tools for musical composition"
  s.description       = s.summary
  s.license           = 'MIT'
  s.authors           = ['BR']
  s.email             = 'miltons.machine@gmail.com'

  s.has_rdoc          = true
  s.rdoc_options      = ['-all', '--inline-source', '--charset=UTF-8']
  s.extra_rdoc_files  = ['README.rdoc']

  s.add_development_dependency("rspec", ">= 2.7.0")

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  # s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
