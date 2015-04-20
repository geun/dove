namespace :load do
  task :defaults do
    set :kibana_version, '4.0.2'
    set :kibana_url, "https://download.elastic.co/kibana/kibana/kibana-#{fetch(:kibana_version)}-linux-x64.tar.gz"
  end
end


namespace :kibana do

  task :install do
# within("/etc/init.d") do
#   execute :sudo, "wget https://raw.github.com/elasticsearch/logstash-forwarder/master/logstash-forwarder.init -O logstash-forwarder"
#   execute :sudo, "chmod +x logstash-forwarder"
#   execute :sudo, "update-rc.d logstash-forwarder default"
# end
    execute :sudo, "wget #{fetch(:kibana_url)} -O kibana4.tar.gz"
    execute :sudo, "tar zxvf kibana4.tar.gz"

  end


end