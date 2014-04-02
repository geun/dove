namespace :logstash do

  task :install do
    on roles(:logstash_indexer) do
      execute "wget #{fetch(:logstash_deb_url)} -O /tmp/logstash.deb"
      execute :sudo, "dpkg -i /tmp/logstash.deb"
    end
  end

  task :initialize, [:force_copy] do |task, args|
    is_force =  args[:force_copy].to_bool unless args[:force_copy].nil?
    local_copy_template :logstash, 'logstash-indexer.conf.erb', is_force
  end

  task :setup do

    on roles(:logstash_indexer) do
      smart_template "logstash-indexer.conf.erb", "/tmp/logstash-indexer.conf" #with faye websocket
      move "/tmp/logstash-indexer.conf", "#{fetch(:logstash_config_dir)}/logstash-indexer.conf"

      execute :sudo, "chown -R logstash:logstash #{fetch(:logstash_config_dir)}"
    end
    invoke 'logstash:restart'
  end

  task :test do

    on roles(:logstash_indexer) do
      within("/opt/logstash/bin") do
        execute :sudo, :sh, "logstash --configtest agent -f #{fetch(:logstash_config_dir)} -l /var/log/logstash/logstash.log "
      end
    end

    #agent -f ${LS_CONF_DIR} -l ${LS_LOG_FILE} ${LS_OPTS}
  end

  task :console do
    on roles(:logstash_indexer) do
      within("/opt/logstash/bin") do
        execute :sudo, "sh logstash agent -f /etc/logstash/conf.d"
      end
    end
  end

  task :generate_ssl_keys do
    run_locally do
      unless test("[ -d #{fetch(:logstash_ssl_folder)} ]")
        cap_info "create ssl_cert folder"
        execute "mkdir ssl_cert"
      end
      execute :openssl, "req -x509 -batch -nodes -newkey rsa:2048 -keyout #{fetch(:logstash_ssl_folder)}/#{fetch(:logstash_ssl_key)}.key -out #{fetch(:logstash_ssl_folder)}/#{fetch(:logstash_ssl_key)}.crt"
    end
  end

  task :upload_ssl do
    on roles([:logstash_forwarder, :logstash_indexer]) do

      unless test("[ -d #{fetch(:ssl_certificate_dir)} ]")
        cap_info "create ssl_cert folder"
        execute :sudo, "mkdir -p #{fetch(:ssl_certificate_dir)}"
        execute :sudo, "chown -R logstash:logstash #{fetch(:ssl_certificate_dir)}"
      end

      unless test("[ -d #{fetch(:ssl_key_dir)} ]")
        cap_info "create ssl_key folder"
        execute :sudo, "mkdir -p #{fetch(:ssl_key_dir)}"
        execute :sudo, "chown -R logstash:logstash #{fetch(:ssl_key_dir)}"
      end

      upload_and_move "#{fetch(:logstash_ssl_folder)}/#{fetch(:logstash_ssl_key)}.crt", "#{fetch(:ssl_certificate_dir)}/#{fetch(:logstash_ssl_key)}.crt"
      upload_and_move "#{fetch(:logstash_ssl_folder)}/#{fetch(:logstash_ssl_key)}.key", "#{fetch(:ssl_key_dir)}/#{fetch(:logstash_ssl_key)}.key"
    end
  end

  %w[start stop restart status].each do |command|
    desc "#{command} logstash"
    task command do
      on roles(:logstash_indexer) do
        execute :sudo, "service logstash #{command}"
      end
    end
  end
end

