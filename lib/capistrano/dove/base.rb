namespace :provisioning do

  desc 'Install server via sshkit'
  task :ssh do
    invoke 'server:install'
    invoke 'server:setup'
  end

  desc 'Install server via puppet'
  task :puppet do

  end

end
