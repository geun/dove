#namespace :bootstrap do
#  desc 'Configures repo and installs Puppet on Ubuntu'
#  task :ubuntu do
#    invoke 'puppet:repo:ubuntu'
#    invoke 'puppet:install:ubuntu'
#  end
#end

namespace :bootstrap do


  desc 'Copy config files to template folder'
  task :initialize do
    #load hiera yml
    invoke "nginx:initialize"
  end

  task :clean do
    invoke "nginx:initialize"
  end

  task :up do


  end



end