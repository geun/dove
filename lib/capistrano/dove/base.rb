require 'capistrano/server/ubuntu'

namespace :provisioning do

  desc 'Install server via sshkit'
  task :ssh do
    invoke 'ubuntu:install'
    invoke 'ubuntu:setup'
  end

  desc 'Install server via puppet'
  task :puppet do

  end

end