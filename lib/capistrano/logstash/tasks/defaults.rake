namespace :load do
  task :defaults do
    #set :logstash_deb_url, "https://github.com/geun/logstash-forwarder-deb/blob/master/logstash-forwarder_0.3.1_amd64.deb"

    set :logstash_version, "1.4.2"
    set :logstash_deb_url, "https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_#{fetch(:logstash_version)}_all.deb"
    set :logstash_config_dir, "/etc/logstash/conf.d"


    set :logstash_forwarder_deb_url, "https://github.com/geun/logstash-forwarder-deb/archive/master.zip"
    set :logstash_forwarder_version, "0.3.1"
    set :logstash_forwarder_dir, "/etc/logstash-forwarder"

    set :logstash_ssl_folder, "ssl_cert"
    set :logstash_remote_ssl_folder, "/etc/logstash-forwarder"
    set :logstash_ssl_key, "logstash-forwarder"

    set :ssl_certificate_dir, "/etc/logstash/ssl"
    set :ssl_key_dir, "/etc/logstash/ssl"

  end
end

