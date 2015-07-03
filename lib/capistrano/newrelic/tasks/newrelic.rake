namespace :newrelic do
  task :install do
    on roles(:all) do
      # execute "sudo su -c echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list"
       execute :sudo, "echo 'deb http://apt.newrelic.com/debian/ newrelic non-free' | sudo tee -a /etc/apt/sources.list.d/newrelic.list"

      # execute :sudo, "wget -O /etc/apt/sources.list.d/newrelic.list http://download.newrelic.com/debian/newrelic.list"
      # execute :sudo, "wget -O- https://download.newrelic.com/548C16BF.gpg | apt-key add -"
      # execute :sudo, "apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF"
      
      #execute :sudo, "echo deb http://apt.newrelic.com/debian/ newrelic non-free >> /etc/apt/sources.list.d/newrelic.list"
      execute :sudo, "wget -O- https://download.newrelic.com/548C16BF.gpg | sudo apt-key add -"
      execute :sudo, "apt-get -y update"
      execute :sudo, "apt-get install newrelic-sysmond"

      unless fetch(:newrelic_nrsysmond_license).nil?
        execute :sudo, "nrsysmond-config --set license_key=#{fetch(:newrelic_nrsysmond_license)}"
      end

    end
  end
  # after "deploy:install", "newrelic:server_monitor:install"

  %w[start stop].each do |command|
    desc "#{command} newrelic-sysmond"
    task command do
      on roles(:all) do
        execute :sudo, "service newrelic-sysmond #{command}"
      end
    end
    # after "torquebox:#{command}", "torquebox:#{command}"
  end
end
