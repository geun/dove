namespace :nginx do
  desc "Install latest stable release of nginx"
  task :install, roles: :web do

    run "#{sudo} add-apt-repository ppa:nginx/stable", pty: true do |ch, stream, data|
      press_enter( ch, stream, data)
    end
    #run "#{sudo} add-apt-repository ppa:nginx/stable"
    run "#{sudo} apt-get -y update"
    #run "#{sudo} apt-get -y install nginx nginx-extras"
    run "#{sudo} apt-get -y install nginx"
  end
  after "deploy:install", "nginx:install"

  task :ipv6, roles: :web do
    run "#{sudo} sed -i 's/default_server/ipv6only=on default_server/g' /etc/nginx/sites-enabled/default"
  end
  after "nginx:install", "nginx:ipv6"

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    #template "nginx_unicorn.erb", "/tmp/nginx_#{application}_site" #default
    template "nginx_unicorn_faye.erb", "/tmp/nginx_#{application}_site" #with faye websocket
    template "nginx.erb", "/tmp/nginx_conf"
    #template "nginx_puma_conf.erb", "/tmp/nginx_conf"
    #template "nginx_puma_site.erb", "/tmp/nginx_#{application}_site"
    run "#{sudo} mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.#{Time.now.utc.strftime("%Y-%m-%d_%I:%M")}.backup"
    run "#{sudo} mv /tmp/nginx_conf /etc/nginx/nginx.conf"
    run "#{sudo} mv /tmp/nginx_#{application}_site /etc/nginx/sites-enabled/#{application}"
    run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
    restart
  end
  after "deploy:setup", "nginx:setup"
  
  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end
end
