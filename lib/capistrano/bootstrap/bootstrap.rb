require 'capistrano/dove/base'
require 'capistrano/server/server'
require 'capistrano/nginx/nginx'
load File.expand_path("../tasks/bootstrap.rake", __FILE__)