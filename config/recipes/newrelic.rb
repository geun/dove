

namespace :newrelic do
  namespace :server_monitor do
    task :install, roles: :web do
      run "#{sudo} wget -O /etc/apt/sources.list.d/newrelic.list http://download.newrelic.com/debian/newrelic.list"
      run "#{sudo} apt-key adv --keyserver hkp://subkeys.pgp.net --recv-keys 548C16BF"
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get install newrelic-sysmond"
      run "#{sudo} nrsysmond-config --set license_key=#{newrelic_nrsysmond_license}"
    end
    after "deploy:install", "newrelic:server_monitor:install"

    %w[start stop].each do |command|
      desc "#{command} unicorn"
      task command, roles: :web do
        run "#{sudo} service newrelic-sysmond #{command}"
      end
      after "deploy:#{command}", "unicorn:#{command}"
    end

    task :uninstall, roles: :web do
    end
  end
end