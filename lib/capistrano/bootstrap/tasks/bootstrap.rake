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

  task :logging_system do
    invoke 'ubuntu:build'
    invoke 'elasticsearch:install'
    invoke 'logstash:install'
    invoke 'logstash_forwarder:install'

    invoke 'logstash:upload_ssl'
    invoke 'logstash:setup'
    invoke 'logstash_forwarder:setup'

    invoke 'elasticsearch:start'
    invoke 'logstash:start'
    invoke 'logstash_forwarder:start'
  end



end