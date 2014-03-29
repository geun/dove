namespace :nginx do
  desc "Install latest stable release of nginx"
  task :install do
      on roles(:nginx) do
        execute :sudo, "echo", "add-apt-repository ppa:nginx/stable"
        execute :sudo, "apt-get -y update"
        execute :sudo, "apt-get -y install nginx"
    end
  end
  after "provisioning:ssh", "nginx:install"

  task :ipv6 do
    on roles(:nginx) do
      execute :sudo, "sed -i 's/default_server/ipv6only=on default_server/g' /etc/nginx/sites-enabled/default"
    end
  end
  after "nginx:install", "nginx:ipv6"

  desc "initiailze nginx config"
  task :initialize do
    run_locally do
      local_copy_template "nginx_unicorn_faye.erb"
      local_copy_template "nginx.erb"
    end
  end

  desc "Setup nginx configuration for this application"
  task :setup do
    on roles(:nginx) do
      application = fetch(:application)
      #template "nginx_unicorn.erb", "/tmp/nginx_#{application}_site" #default
      smart_template "nginx_unicorn_faye.erb", "/tmp/nginx_#{application}_site" #with faye websocket
      smart_template "nginx.erb", "/tmp/nginx_conf"

      #template "nginx_puma_conf.erb", "/tmp/nginx_conf"
      #template "nginx_puma_site.erb", "/tmp/nginx_#{application}_site"
      execute :sudo, "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.#{Time.now.utc.strftime("%Y-%m-%d_%I:%M")}.backup"
      execute :sudo, "mv /tmp/nginx_conf /etc/nginx/nginx.conf"
      execute :sudo, "mv /tmp/nginx_#{application}_site /etc/nginx/sites-enabled/#{application}"
      execute :sudo, "rm -f /etc/nginx/sites-enabled/default"
      restart
    end
  end
  #after "deploy:setup", "nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command do
      on roles(:nginx) do
        execute :sudo, "service nginx #{command}"
      end

    end
  end
end
