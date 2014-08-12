namespace :load do
  task :defaults do
    set :torquebox_dist_url, "http://torquebox.org/release/org/torquebox/torquebox-dist/3.1.0/torquebox-dist-3.1.0-bin.zip"
    set :jboss_init_sh, "jboss-as-standalone.erb"
    set :jboss_init_upstart_sh, "torquebox.conf.erb"
    set :jboss_as_conf, "jboss-as.conf.erb"
    set :jboss_pid, ->{ "#{shared_path.join('pid')}/jboss-as-standalone.pid" }
    set :jboss_log, ->{ "#{shared_path.join('log')}/torquebox.log" }
    set :jboss_config,  fetch(:jboss_config, "standalone.xml")
    set :jboss_standalone_config,  fetch(:jboss_standalone_config, "standalone.conf.erb")

    set :torquebox_home,       fetch(:torquebox_home,       '/opt/torquebox')
    set :jruby_home,           fetch(:jruby_home,           "#{fetch(:torquebox_home)}/jruby")
    set :jruby_opts,           fetch(:jruby_opts,           "--#{fetch(:app_ruby_version)}" ) if fetch(:app_ruby_version) && !fetch(:jruby_opts)
    set :jruby_bin,            fetch(:jruby_bin,            "#{fetch(:jruby_home)}/bin/jruby #{fetch(:jruby_opts)}"      )
    set :jboss_home,           fetch(:jboss_home,           "#{fetch(:torquebox_home)}/jboss")
    set :jboss_control_style,  fetch(:jboss_control_style,  'initd' )
    set :jboss_init_script,    fetch(:jboss_init_script,    '/etc/init.d/jboss-as-standalone')
    set :jboss_as_conf_path,   fetch(:jboss_as_conf_path,      '/etc/jboss-as/jboss-as.conf')
    set :jboss_runit_script,   fetch(:jboss_runit_script,   '/etc/service/torquebox/run')
    set :jboss_upstart_script, fetch(:jboss_upstart_script, '/etc/init/torquebox.conf')
    set :jboss_bind_address,   fetch(:jboss_bind_address,   '0.0.0.0')
    set :bundle_cmd,           fetch(:bundle_cmd,           "#{fetch(:jruby_bin)} -S bundle")
    set :bundle_flags,         fetch(:bundle_flags,         '')

  end
end