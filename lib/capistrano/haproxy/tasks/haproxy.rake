namespace :load do
  task :defaults do

    set :haproxy_path, "/etc/haproxy"
    set :haproxy_global, -> {

          {
              #"chroot" => "/usr/share/haproxy",
              "daemon" => "",
              "group" => fetch(:haproxy_group, "haproxy"),
              #"quiet" => "",
              "spread-checks" => 0,
              "user" => fetch(:haproxy_user, "haproxy"),
              "tune.maxaccept" => 100,
          }
    }
    set :haproxy_defaults, -> {
      {
        "balance" => "roundrobin",
        "grace" => 0,
        "log" => "global",
        "maxconn" => fetch(:haproxy_connections, 65535),
        "mode" => "tcp",
        "option" => [
            "clitcpka",
            "contstats",
            "dontlognull",
            "redispatch",
            #"splice-auto",
            "srvtcpka",
            #"transparent",
        ],
        "retries" => 3,
        "timeout" => [
            "client #{fetch(:haproxy_client_tieout, '1h')}",
            "connect #{fetch(:haproxy_connct_timeout, '3s')}",
            "server #{fetch(:haproxy_server_timeout, '1h')}",
        ],
      }
    }
    set :haproxy_listens, -> {}
  end
end

namespace :haproxy do
  desc "Setup HAProxy."



  desc "initiailze nginx config"
  task :initialize, [:force_copy] do |task, args|
    is_force =  args[:force_copy].to_bool unless args[:force_copy].nil?
    local_copy_template :haproxy, 'nginx_unicorn_faye.erb', is_force
    local_copy_template :nginx, "nginx.erb", is_force
  end


  desc "Install latest stable release of haproxy"
  task :install do
    on roles(:haproxy) do
      execute :sudo, "apt-get -y install haproxy"
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