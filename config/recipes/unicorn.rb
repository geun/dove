set_default(:unicorn_user) { user }
set_default(:unicorn_pid) { "#{current_path}/tmp/pids/unicorn.pid" }
set_default(:unicorn_config) { "#{shared_path}/config/unicorn.rb" }
set_default(:unicorn_log) { "#{shared_path}/log/unicorn.log" }
set_default(:unicorn_workers,3)


namespace :unicorn do
  desc "Setup Unicorn initializer and app configuration"

  task :install, roles: :app do
    run "gem install unicorn --no-ri --no-rdoc"
    run "rbenv rehash"
  end
  after "deploy:install", "unicorn:install"

  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "unicorn.rb.erb", unicorn_config
    template "unicorn_init.erb", "/tmp/unicorn_init"
    run "chmod +x /tmp/unicorn_init"
    run "#{sudo} mv /tmp/unicorn_init /etc/init.d/unicorn_#{application}"
    run "#{sudo} update-rc.d -f unicorn_#{application} defaults"
  end
  after "deploy:setup", "unicorn:setup"

  %w[start restart stop].each do |command|
    desc "#{command} unicorn"
    task command, roles: :app do
      run "service unicorn_#{application} #{command}"
    end
    after "deploy:#{command}", "unicorn:#{command}"
  end

  #task :restart, roles: :app do
  #  stop
  #  start
  #end
  #after "deploy:restart", "unicorn:restart"

end
