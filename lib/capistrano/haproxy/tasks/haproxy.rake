namespace :haproxy do
  desc "Setup HAProxy."

  desc "initiailze haproxy config"
  task :initialize, [:force_copy] do |task, args|
    is_force =  args[:force_copy].to_bool unless args[:force_copy].nil?
    local_copy_template :haproxy, 'haproxy.cfg.erb', is_force
    local_copy_template :haproxy, "haproxy.erb", is_force
  end


  desc "Install latest stable release of haproxy"
  task :install do
    on roles(:haproxy) do
      execute :sudo , "add-apt-repository ppa:vbernat/haproxy-1.5"
      execute :sudo, "apt-get update"
      execute :sudo, "apt-get -y install haproxy"
    end
  end

  task :uninstall do
    on roles(:haproxy) do
      execute :sudo , "apt-get remove haproxy"

    end

  end

  task :setup do
    invoke 'haproxy:update'
    invoke 'haproxy:restart'
  end

  desc 'update haproxy config file'
  task :update do

    on roles(:haproxy) do
      smart_template "haproxy.cfg.erb", "/tmp/haproxy_cfg"
      smart_template "haproxy.erb", "/tmp/haproxy_script" #/etc/default/haproxy

      installed_path = fetch(:haproxy_path)
      execute :sudo, "mv /etc/default/haproxy /etc/default/haproxy.#{Time.now.utc.strftime("%Y-%m-%d_%I:%M")}.backup"
      execute :sudo, "mv /tmp/haproxy_script /etc/default/haproxy"
      execute :sudo, "mv /tmp/haproxy_cfg /etc/haproxy/haproxy.cfg"
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} haproxy"
    task command do
      on roles(:haproxy) do
        execute :sudo, "service haproxy #{command}"
      end

    end
  end


end