desc "Run rake task on server"
task :rake do
  on primary fetch(:migration_role) do
    within current_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, ENV['task']
      end
    end
  end
end

#https://gist.github.com/toobulkeh/8214198
namespace :rails do
  desc "Open the rails console on each of the remote servers"
  task :console do
    on roles(:app) do |host| #does it for each host, bad.
      rails_env = fetch(:stage)
      execute_interactively "bundle exec rails console #{rails_env}"
    end
  end

  desc "Open the rails dbconsole on each of the remote servers"
  task :dbconsole do
    on roles(:app) do |host| #does it for each host, bad.
      rails_env = fetch(:stage)
      execute_interactively "bundle exec rails dbconsole #{rails_env}"
    end
  end

  def execute_interactively(command)
    user = fetch(:user)
    port = fetch(:port) || 22
    exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
  end
end


