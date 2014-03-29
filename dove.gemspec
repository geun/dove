# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/dove/version'

Gem::Specification.new do |gem|

  gem.name        = 'dove'
  gem.version     = Capistrano::Dove::VERSION
  gem.date        = '2014-03-21'
  gem.summary     = "for deployment"
  gem.description = "for deployment111"
  gem.authors     = ["Geun"]
  gem.email       = ["geunbaelee@gmail.com"]
  gem.homepage    = 'https://github.com/geun/dove'
  gem.license     = 'MIT'

  gem.files       = `git ls-files`.split($/)
  gem.require_paths = ["lib"]

  gem.add_dependency 'capistrano', '~> 3.1'
  gem.add_dependency 'capistrano-bundler', '~> 1.1'
  gem.add_dependency 'hiera', '~> 1.3.2' #lastest version
  gem.add_dependency 'sshkit', '~> 1.3'
  gem.add_dependency 'colorize', '~> 0.7.0'

  gem.post_install_message = <<eos
have a good time!
eos

end
