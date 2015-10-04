# -*- encoding: utf-8 -*-

require_relative 'lib/capistrano/rsync/version'

Gem::Specification.new do |s|

  s.name        = Capistrano::Rsync::NAME
  s.version     = Capistrano::Rsync::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = Capistrano::Rsync::AUTHORS
  s.email       = Capistrano::Rsync::EMAIL
  s.homepage    = Capistrano::Rsync::HOMEPAGE
  s.summary     = Capistrano::Rsync::SUMMARY
  s.description = Capistrano::Rsync::DESCRIPTION
  s.license     = Capistrano::Rsync::LICENSE

  s.has_rdoc         = false
  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.files            = `git ls-files `.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables      = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths    = ["lib"]

  s.required_ruby_version = '~> 2.1'

  s.add_runtime_dependency 'capistrano', '>= 3.4', '< 4'

end

