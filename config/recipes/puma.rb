#set_default(:unicorn_user) { user }
set_default(:puma_role) { :app }
set_default(:min_threads, 4)
set_default(:max_threads, 4)


namespace :puma do
  desc "Setup puma initializer and app configuration"

  task :install, roles: :app do
    run "gem install puma --no-ri --no-rdoc"
    run "rbenv rehash"
  end
  after "deploy:install", "puma:install"


  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/tmp"
    run "mkdir -p #{shared_path}/sockets"
  end
  #task :setup, roles: :app do
  #  desc "Copy puma junggler"
  #  run "mkdir -p #{shared_path}/config"
  #  run "mkdir -p #{shared_path}/tmp"
  #  run "mkdir -p #{shared_path}/tmp/puma"
  #
  #  template "puma_command.erb", "/tmp/puma_command"
  #  template "run-puma.erb", "/tmp/run-puma"
  #
  #  run "chmod +x /tmp/puma_command"
  #  run "chmod +x /tmp/run-puma"
  #
  #  run "#{sudo} mv /tmp/puma_command /etc/init.d/puma"
  #  run "#{sudo} mv /tmp/run-puma /usr/local/bin"
  #  run "#{sudo} cp puma /etc/init.d"
    #run "#{sudo} chmod +x /etc/init.d/puma"
    #run "#{sudo} chmod +x /usr/local/bin/run-puma"
#
# Make it start at boot time.
#    run "#{sudo} update-rc.d -f puma defaults"
#    run "#{sudo} touch /etc/puma.conf"
#  end
  after "deploy:setup", "puma:setup"

  task :add, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "puma_config.rb.erb", "#{shared_path}/config/puma.rb"
    run "#{sudo} /etc/init.d/puma add #{current_path} #{user} #{shared_path}/config/puma.rb #{shared_path}/log/puma.log"
    #run "#{sudo} /etc/init.d/puma add #{current_path} #{user}"
  end


  task :update, roles: :app do
    desc "refreash puma puma config"
    remove
    add
  end
  #after "deploy:update", "puma:update"


  task :remove, roles: :app do
    run "#{sudo} /etc/init.d/puma remove #{current_path}"
  end

  #desc "Start Puma"
  #task :start, roles: :app do
  #
  #  #run "/etc/init.d/puma start #{application}"
  #  #run "#{sudo} /etc/init.d/puma start #{application}"
  #  run "#{sudo} service puma start"
  #end
  #after "deploy:start", "puma:start"
  #
  #desc "Stop Puma"
  #task :stop, roles: :app do
  #  #run "/etc/init.d/puma stop #{application}"
  #  run "#{sudo} /etc/init.d/puma stop #{application}"
  #end
  #after "deploy:stop", "puma:stop"
  #
  #desc "Restart Puma"
  #task :restart, roles: :app do
  #  run "#{sudo} /etc/init.d/puma restart #{application}"
  #end
  #after "deploy:restart", "puma:restart"



  desc "Start puma"
  task :start, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    puma_env = fetch(:rack_env, fetch(:rails_env, "production"))
    run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec puma -d -e #{puma_env} -t #{min_threads}:#{max_threads} -b 'unix://#{shared_path}/sockets/#{application}-puma.sock' -S #{shared_path}/sockets/#{application}-puma.state --control 'unix://#{shared_path}/sockets/#{application}-pumactl.sock' >> #{shared_path}/log/puma.log 2>&1", :pty => false
    #run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec puma -d -e #{puma_env} -b 'unix://#{shared_path}/sockets/puma.sock' -S #{shared_path}/sockets/#{application}-puma.state --control 'unix://#{shared_path}/sockets/pumactl.sock'", :pty => false
    #run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec puma -d -e #{puma_env} -b 'unix://#{shared_path}/sockets/puma.sock' -S #{shared_path}/sockets/#{application}-puma.state --control 'unix://#{shared_path}/sockets/pumactl.sock'", :pty => false
    #run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec puma -S #{shared_path}/config/puma.rb 2>&1 >> #{shared_path}/log/puma.log ", :pty => false
  end
  after "deploy:start", "puma:start"

  desc "Stop puma"
  task :stop, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec pumactl -S #{shared_path}/sockets/#{application}-puma.state stop"
    #run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec pumactl -S #{shared_path}/tmp/puma/state stop"
  end
  after "deploy:stop", "puma:stop"

  desc "Restart puma"
  task :restart, :roles => lambda { fetch(:puma_role) }, :on_no_matching_servers => :continue do
    #run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec pumactl -S #{shared_path}/sockets/#{application}-puma.state restart"
    #run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec pumactl -S #{shared_path}/tmp/puma/state restart"
    stop
    start
  end
  #after "deploy:restart", "puma:restart"

  task :status, roles: :app do
    #run "#{sudo} /etc/init.d/puma status"
    #run "cd #{current_path} && #{fetch(:bundle_cmd, "bundle")} exec pumactl -S #{shared_path}/sockets/#{application}-puma.state status"
  end

  #task :overview, roles: :app do
  #  run "#{sudo} /etc/init.d/puma status"
  #end
  #
  #task :start_hard, roles: :app do
  #  run "run-puma #{current_path} #{shared_path}/config/puma.rb #{shared_path}/log/puma.log"
  #end



  desc "create a shared tmp dir for puma state files"
  task :after_symlink, roles: :app do
    run "#{sudo} rm -rf #{release_path}/tmp"
    run "ln -s #{shared_path}/tmp #{release_path}/tmp"
  end
  after "deploy:create_symlink", "puma:after_symlink"


end
