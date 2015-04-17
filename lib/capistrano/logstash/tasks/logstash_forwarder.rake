

namespace :logstash_forwarder do

  task :initialize, [:force_copy] do |task, args|
    is_force =  args[:force_copy].to_bool unless args[:force_copy].nil?
    local_copy_template :logstash, 'logstash-forwarder.conf.erb', is_force
  end


  task :install do
    on roles(:logstash_forwarder) do

      execute :sudo, :echo, "deb http://packages.elasticsearch.org/logstashforwarder/debian stable main | sudo tee /etc/apt/sources.list.d/logstashforwarder.list"
      execute :sudo, 'apt-get update'
      execute :sudo, 'apt-get -y --force-yes install logstash-forwarder'

      # within("/etc/init.d") do
      #   execute :sudo, "wget https://raw.github.com/elasticsearch/logstash-forwarder/master/logstash-forwarder.init -O logstash-forwarder"
      #   execute :sudo, "chmod +x logstash-forwarder"
      #   execute :sudo, "update-rc.d logstash-forwarder default"
      # end

      # execute "wget #{fetch(:logstash_forwarder_deb_url)} -O /tmp/logstash-forwarder.zip"
      # execute :sudo, "unzip /tmp/logstash-forwarder.zip -d /tmp/"
      #
      # within("/tmp/logstash-forwarder-deb-master") do
      #   execute :sudo, "dpkg -i logstash-forwarder_#{fetch(:logstash_forwarder_version)}_amd64.deb"
      # end
      # execute :sudo, "rm -rf /tmp/logstash-forwarder-deb-master"


    end
  end

  task :setup do
    on roles(:logstash_forwarder) do
      smart_template "logstash-forwarder.conf.erb", "/tmp/logstash-forwarder.conf" #with faye websocket

      #unless test("[ -d #{fetch(:logstash_forwarder_dir)} ]")
      #  cap_info "Create #{fetch(:logstash_forwarder_dir)}"
      #  execute :sudo, :mkdir, fetch(:logstash_forwarder_dir)
      #end
      move "/tmp/logstash-forwarder.conf", "/etc/logstash-forwarder"
    end
    invoke 'logstash_forwarder:restart'
  end

  %w[start stop restart status].each do |command|
    desc "#{command} logstash_forwarder"
    task command do
      on roles(:logstash_forwarder) do
        execute :sudo, "service logstash-forwarder #{command}"
      end
    end
  end
end
#/opt/logstash-forwarder/bin/logstash-forwarder -config /etc/logstash-forwarder -spool-size 100 -log-to-syslog