namespace :nginx do
  desc "initiailze nginx config"
  task :initialize, [:force_copy] do |task, args|
    is_force =  args[:force_copy].to_bool unless args[:force_copy].nil?
    local_copy_template :nginx, 'nginx_unicorn_faye.erb', is_force
    local_copy_template :nginx, "nginx.erb", is_force
  end

  desc "Install latest stable release of nginx"
  task :install do
      on roles(:web) do
        execute :sudo, "echo", "add-apt-repository ppa:nginx/stable"
        execute :sudo, "apt-get -y update"
        execute :sudo, "apt-get -y install nginx"
        execute :sudo, "apt-get -y install nginx-extras"
      end
      invoke 'nginx:ipv6'
  end
  #after "provisioning:ssh", "nginx:install"

  task :ipv6 do
    on roles(:web) do
      execute :sudo, "sed -i 's/default_server/ipv6only=on default_server/g' /etc/nginx/sites-enabled/default"
    end
  end
  #after "nginx:install", "nginx:ipv6"

  desc "Setup nginx configuration for this application"
  task :setup do
    on roles(:web) do
      application = fetch(:application)
      smart_template fetch(:nginx_config), "/tmp/nginx_conf"
      smart_template fetch(:nginx_mime_type), "/tmp/mime.types"

      if test("[ -e /etc/nginx/nginx.conf ]")
        execute :sudo, "mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.#{Time.now.utc.strftime("%Y-%m-%d_%I:%M")}.backup"
      end
      execute :sudo, "mv /tmp/nginx_conf /etc/nginx/nginx.conf"
      execute :sudo, "mv /tmp/mime.types /etc/nginx/mime.types"
      if test("[ -e /etc/nginx/sites-enabled/default ]")
        execute :sudo, "rm -f /etc/nginx/sites-enabled/default"
      end
    end
    invoke 'nginx:restart'
  end
  #after "deploy:setup", "nginx:setup"


  namespace :config do
    desc 'Deploy nginx config'
    task :deploy, [:filename, :name] do |t, args|
      on roles(:web), in: :parallel do
        raise 'invalid filename' if args[:filename].nil?
        filename = args[:filename]
        name = if args[:name].nil? then fetch(:full_app_name) else args[:name] end
        smart_template "#{filename}", "/tmp/nginx_#{name}" #with faye websocket
        execute :sudo, "mv /tmp/nginx_#{name} /etc/nginx/sites-enabled/#{name}"
      end
      invoke 'nginx:restart'
    end

    desc 'Undeploy nginx config'
    task :undeploy, [:name] do |t, args|
      on roles(:web), in: :parallel do |host|
        raise 'invalid filename' if args[:name].nil?
        name = args[:name]
        execute :sudo, "rm /etc/nginx/sites-enabled/#{name}"
      end
      invoke 'nginx:restart'
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command do
      on roles(:web) do
        execute :sudo, "service nginx #{command}"
      end

    end
  end
end
