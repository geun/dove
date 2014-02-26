# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'logging_intra'
set :repo_url, 'git@gitbub.com:geun/logging_intra.git'

# Deploy user
# set :user, "deploy"

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }


# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/home/#{user}/#{application}"
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

set :path, "/home/#{user}/.rbenv/bin:/home/#{user}/.rbenv/shims/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:$PATH"

set :default_env, {
    'RBENV_ROOT' => "/home/#{user}/.rbenv/",
    'PATH' => path,
    'RAILS_ENV' => rails_env
}

# Default value for keep_releases is 5
set :keep_releases, 5

#https://semaphoreapp.com/blog/2013/11/26/capistrano-3-upgrade-guide.html
#set :linked_files, %w{config/database.yml config/config.yml}
#set :linked_dirs, %w{bin log tmp vendeor/bundle public/system}
#SSHKit.config.command_map[:rake] = "bundle exec rake"
#SSHKit.config.command_map[:rails] = "bundle exec rake"

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
