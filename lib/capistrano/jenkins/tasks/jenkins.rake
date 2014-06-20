namespace :load do

  namespace :defaults do
    set :jenkins_proxy_config, "nginx_jenkins.erb"
  end

end

namespace :jenkins do

  task :install do
    on roles(:jenkins) do
      execute "wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -"
      execute "sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'"
      execute "sudo apt-get -y update"
      execute "sudo apt-get -y install jenkins"
      execute "sudo apt-get -y install build-essential bison openssl libreadline5 libreadline-dev curl git-core zlib1g zlib1g-dev libssl-dev libxslt-dev libsqlite3-0 libsqlite3-dev sqlite3 libreadline-dev libxml2-dev autoconf libtool openssh-server"
      execute "sudo apt-get -y install build-essential git-core curl wget openssl libssl-dev libopenssl-ruby libmysqlclient-dev ruby-dev mysql-client libmysql-ruby xvfb firefox libsqlite3-dev libxslt-dev libxml2-dev libicu48"
      execute "sudo aptitude -y install libpq-dev"
      execute "sudo apt-get -y install postgresql postgresql-client"
    end
  end

  desc "initiailze nginx-jenkins config"
  task :initialize, [:force_copy] do |task, args|
    is_force =  args[:force_copy].to_bool unless args[:force_copy].nil?
    local_copy_template :jenkins, "#{fetch(:jenkins_proxy_config)}", is_force
  end

  task :setup do
    invoke 'jenkins:update'
    invoke 'jenkins:restart'
  end

  desc 'update jenkins config file'
  task :update do
    on roles(:jenkins) do
      smart_template "#{fetch(:jenkins_proxy_config)}", "/tmp/jenkins_config"
      execute :sudo, "mv /tmp/jenkins_config /etc/nginx/sites-enabled/jenkins"
    end
  end

  task :set_rspec_config do
    #SPEC_OPTS="--format html" rake spec > jenkins/rspec.html
  end
  task :set_rspec_config do

  end
  task :set_rspec_config do

  end
  task :set_rspec_config do

  end


  %w[start stop restart].each do |command|
    desc "#{command} haproxy"
    task command do
      on roles(:jenkins) do
        execute :sudo, "service jenkins #{command}"
      end

    end
  end

end