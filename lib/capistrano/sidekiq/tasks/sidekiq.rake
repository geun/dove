namespace :defaults do
  set :sidekiq_config_path, "sidekiq.yml.erb"
end

namespace :sidekiq do
  desc 'config sidekiq.yml'
  task :config do

    on roles(fetch(:sidekiq_role)) do
      sidekiq_config_file = shared_path.join('config/sidekiq.yml')
      unless test "[ -d #{sidekiq_config_file} ]"
        execute :mkdir, '-pv',  shared_path.join('config')
      end

      smart_template fetch(:sidekiq_config_path), "/tmp/sidekiq.yml"
      execute :sudo, "mv /tmp/sidekiq.yml #{shared_path}/config/sidekiq.yml"
    end
  end
end