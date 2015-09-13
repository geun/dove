namespace :defaults do
  set :puma_config, "puma.rb.erb"
  set :puma_upstart_manager_config, "puma-manager.conf.erb"
  set :puma_upstart_config, "puma.conf.erb"
  set :puma_etc_apps_config, "etc_puma.conf.erb"
end


namespace :puma do
  task :install do
    on roles(:app) do
      smart_template fetch(:puma_upstart_config), "/tmp/puma.conf"
      smart_template fetch(:puma_upstart_manager_config), "/tmp/puma-manager.conf"
      execute :sudo, 'chown root:root /tmp/puma.conf'
      execute :sudo, 'chown root:root /tmp/puma-manager.conf'
      # execute :sudo, 'chmod 0755 /tmp/puma.conf.erb'
      # execute :sudo, 'chmod 0755 /tmp/puma-manager.conf.erb'
      execute :sudo, "mv /tmp/puma.conf /etc/init/puma.conf"
      execute :sudo, "mv /tmp/puma-manager.conf /etc/init/puma-manager.conf"
    end
  end

  desc 'config puma.rb'
  task :config do

    on roles(:app) do
      puma_config_file = shared_path.join('config/puma.rb')
      unless test "[ -d #{puma_config_file} ]"
        execute :mkdir, '-pv',  shared_path.join('config')
      end

      smart_template fetch(:puma_config), "/tmp/puma.rb"
      execute :sudo, "mv /tmp/puma.rb #{shared_path}/config/puma.rb"
    end
  end

  task :setup_apps do
    on roles(:app) do
      smart_template fetch(:puma_etc_apps_config), "/tmp/puma.conf"
      execute :sudo, "mv /tmp/puma.conf /etc/puma.conf"
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} puma"
    task command do
      on roles(:app) do
        with rails_env: fetch(:rails_env) do
          execute :sudo, "#{command} puma-manager"
        end
      end
    end
    #after "deploy:#{command}", "redis:#{command}"
  end

  task :symlink do
    set :linked_files, fetch(:linked_files, []).push('config/puma.rb')
  end
  after 'deploy:started', 'puma:symlink'



end



