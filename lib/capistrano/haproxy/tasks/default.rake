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