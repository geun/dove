namespace :load do

  task :defaults do
    set :elasticsearch_version, "1.1.0"
    set :elasticsearch_deb_url, "https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-#{fetch(:elasticsearch_version)}.deb"
    set :elasticsearch_bin_path, "/usr/share/elasticsearch/bin"
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

        execute :sudo, :sh, "plugin -url http://download.elasticsearch.org/kibana/kibana/kibana-latest.zip -install elasticsearch/kibana3"
      end
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