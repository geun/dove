namespace :load do
  task :defaults do
    set :elasticsearch_version, "1.7.0"
    set :elasticsearch_deb_url, "https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-#{fetch(:elasticsearch_version)}.deb"
    set :elasticsearch_bin_path, "/usr/share/elasticsearch/bin"
    set :elasticsearch_config, "elasticsearch.yml.erb"
  end
end

namespace :elasticsearch do
  task :install do
    on roles(:elasticsearch) do
      execute "wget #{fetch(:elasticsearch_deb_url)} -O /tmp/elasticsearch.deb"
      execute :sudo, "dpkg -i /tmp/elasticsearch.deb"
      execute "rm /tmp/elasticsearch.deb"

      within(fetch(:elasticsearch_bin_path)) do

        #for management clustering of elastic search #https://github.com/mobz/elasticsearch-head
        execute :sudo, :sh, "plugin -install mobz/elasticsearch-head"

        #Live charts and statistics for elasticsearch cluster
        #http://bigdesk.org/v/2.4.0/#nodes
        execute :sudo, :sh, "plugin -install lukas-vlcek/bigdesk"

        execute :sudo, :sh, "plugin -install elasticsearch/elasticsearch-cloud-aws/2.7.0"

        # http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/setup-service.html
        execute :sudo, "update-rc.d elasticsearch defaults 95 10"
      end
    end
  end

  task :setup do
    on roles(:elasticsearch) do
      smart_template fetch(:elasticsearch_config), "/tmp/elasticsearch.yml" #with faye websocket
      execute :sudo, "mv /tmp/elasticsearch.yml /etc/elasticsearch.yml"
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} elasticsearch"
    task command do
      on roles(:elasticsearch) do
        execute :sudo, "service elasticsearch #{command}"
      end
    end
  end

end