set_default(:faye_user) { user }
set_default(:faye_pid) { "#{current_path}/tmp/pids/faye.pid" }
set_default(:faye_log) { "#{shared_path}/log/faye.log" }

namespace :faye do
  desc "Setup Faye initializer"
  task :setup, roles: :app do
    template "faye_init.erb", "/tmp/faye_init"
    run "chmod +x /tmp/faye_init"
    run "#{sudo} mv /tmp/faye_init /etc/init.d/faye_#{application}"
    run "#{sudo} update-rc.d -f faye_#{application} defaults"
  end
  after "deploy:setup", "faye:setup"

  #desc "Start Faye"
  #task :start do
  #  run "cd #{current_path} && rbenv exec rackup #{faye_config} -s thin -E production -D --pid #{faye_pid}"
  #end
  #
  #desc "Stop Faye"
  #task :stop do
  #  run "kill `cat #{faye_pid}` || true"
  #end
  #
  #desc "Restar Faye"
  #task :restart do
  #  stop
  #  start
  #end

  #before 'deploy:update_code', 'faye:stop'
  #after 'deploy:finalize_update', 'faye:start'


  %w[start stop restart].each do |command|
    desc "#{command} faye"
    task command, roles: :app do
      run "service faye_#{application} #{command}"
    end
    #after "deploy:#{command}", "faye:#{command}"
  end
end