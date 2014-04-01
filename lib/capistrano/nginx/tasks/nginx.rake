namespace :load do
  task :defaults do
    set :templates_path, "config/deploy/templates"
    set :nginx_server_name, -> { "localhost #{fetch(:application)}.local" }
    set :nginx_config_name, -> { "#{fetch(:application)}_#{fetch(:stage)}" }
    set :nginx_use_ssl, false

    set :nginx_pid, "/run/nginx.pid"

    set :nginx_ssl_certificate, -> { "#{fetch(:nginx_server_name)}.crt" }
    set :nginx_ssl_certificate_key, -> { "#{fetch(:nginx_server_name)}.key" }
    set :nginx_upload_local_certificate, true
    set :nginx_ssl_certificate_local_path, -> { ask(:nginx_ssl_certificate_local_path, "Local path to ssl certificate: ") }
    set :nginx_ssl_certificate_key_local_path, -> { ask(:nginx_ssl_certificate_key_local_path, "Local path to ssl certificate key: ") }
    set :nginx_config_path, "/etc/nginx/sites-available"

    set :unicorn_service_name, -> { "unicorn_#{fetch(:application)}_#{fetch(:stage)}" }
    set :unicorn_pid, -> { shared_path.join("pids/unicorn.pid") }
    set :unicorn_config, -> { shared_path.join("config/unicorn.rb") }
    set :unicorn_log, -> { shared_path.join("log/unicorn.log") }
    set :unicorn_user, -> { fetch(:user) }
    set :unicorn_workers, 2
    set :sudo, "sudo"
  end
end

namespace :nginx do

  desc "initiailze nginx config"
  task :initialize, [:force_copy] do |task, args|
    is_force =  args[:force_copy].to_bool unless args[:force_copy].nil?
    local_copy_template :nginx, 'nginx_unicorn_faye.erb', is_force
    local_copy_template :nginx, "nginx.erb", is_force
  end


  desc "Install latest stable release of nginx"
  task :install do
      on roles(:nginx) do
        execute :sudo, "echo", "add-apt-repository ppa:nginx/stable"
        execute :sudo, "apt-get -y update"
        execute :sudo, "apt-get -y install nginx"
      end
      invoke 'nginx:ipv6'
  end
  #after "provisioning:ssh", "nginx:install"


  task :ipv6 do
    on roles(:nginx) do
      execute :sudo, "sed -i 's/default_server/ipv6only=on default_server/g' /etc/nginx/sites-enabled/default"
    end
  end
  #after "nginx:install", "nginx:ipv6"

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
