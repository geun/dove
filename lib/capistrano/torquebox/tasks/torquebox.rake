namespace :torquebox do

  desc 'Install torquebox'
  task :install do
    on roles(:app) do

      # execute :sudo, "apt-get -y update"
      # execute :sudo, "apt-get -y install wget unzip"
      unless test "[ -e ~/torquebox-dist-3.1.1-bin.zip ]"
        execute :wget, "http://torquebox.org/release/org/torquebox/torquebox-dist/3.1.1/torquebox-dist-3.1.1-bin.zip"
      end

      execute :unzip, "torquebox-dist-3.1.1-bin.zip -d ~"
      if test "[ -d #{fetch(:torquebox_home)} ]"
        execute :sudo, "rm -rf #{fetch(:torquebox_home)}"
      end
      execute :sudo, "mv ~/torquebox-3.1.1 #{fetch(:torquebox_home)}"

      unless test "[ -d #{shared_path.join('pid')} ]"
        execute :mkdir, "-pv #{shared_path.join('pid')}"
      end
      unless test "[ -d #{shared_path.join('log')} ]"
        execute :mkdir, "-pv #{shared_path.join('log')}"
      end
    end
  end

  desc 'Install Gem'
  task :install_gem do
    on roles(:app) do
      execute 'gem install torquebox-server'
      execute 'rbenv rehash'
    end
  end

  desc 'Setup torquebox'
  task :setup do
    on roles(:app) do

      case fetch(:jboss_control_style)
        when 'initd'
          smart_template "#{fetch(:jboss_init_sh)}", "/tmp/jboss-as-standalone"
          execute "chmod +x /tmp/jboss-as-standalone"
          execute :sudo, "chown root /tmp/jboss-as-standalone"
          execute :sudo, "mv /tmp/jboss-as-standalone /etc/init.d/jboss-as-standalone"

          smart_template "#{fetch(:jboss_as_conf)}", "/tmp/jboss-as-conf"
          unless test "[ -d #{fetch(:jboss_as_conf_path)} ] "
            execute :sudo, "mkdir -pv /etc/jboss-as/"
          end
          execute :sudo, "mv /tmp/jboss-as-conf #{fetch(:jboss_as_conf_path)}"

          smart_template "#{fetch(:jboss_config)}", "/tmp/#{fetch(:jboss_config)}"
          execute :sudo, "mv /tmp/#{fetch(:jboss_config)} #{fetch(:jboss_home)}/standalone/configuration/#{fetch(:jboss_config)}"

        # execute :sudo, "update-rc.d -f jboss-as-standalone defaults"

        when 'binscripts'
          raise 'not implemenets'
        when 'runit'
          raise 'not implemenets'
        when 'upstart'
          smart_template "#{fetch(:jboss_config)}", "/tmp/#{fetch(:jboss_config)}"
          execute :sudo, "mv /tmp/#{fetch(:jboss_config)} #{fetch(:jboss_home)}/standalone/configuration/#{fetch(:jboss_config)}"

          smart_template "#{fetch(:jboss_init_upstart_sh)}", "/tmp/torquebox.conf"
          execute :sudo, "mv /tmp/torquebox.conf #{fetch(:jboss_upstart_script)}"
      end

      smart_template "#{fetch(:jboss_standalone_config)}", "/tmp/standalone.conf"
      execute :sudo, "mv /tmp/standalone.conf #{fetch(:jboss_home)}/bin"

      bash_profile = StringIO.new <<-BASH
export PATH=/usr/lib/postgresql/9.3/bin:/bin:/usr/local/bin:/usr/bin:$PATH
export TORQUEBOX_HOME="#{fetch(:torquebox_home)}"
export JBOSS_HOME="#{fetch(:jboss_home)}"
export JRUBY_OPTS="-J-XX:ReservedCodeCacheSize=256m -J-Xmn1048m -J-Xms2048m -J-Xmx2048m -J-server"
export JRUBY_OPTS="-Xcompile.invokedynamic=false -J-XX:+TieredCompilation -J-XX:TieredStopAtLevel=1 -J-noverify -Xcompile.mode=OFF $JRUBY_OPTS"
if [ -f ~/.bashrc ]; then
   source ~/.profile
fi
      BASH
      upload! bash_profile, "/tmp/bash_profile"
      execute "cat /tmp/bash_profile > ~/.bash_profile"
      execute "source ~/.bash_profile"

    end
  end

  task :remove_setup do
    on roles(:app) do

      case fetch(:jboss_control_style)
        when 'initd'
          execute :sudo, "rm /etc/init.d/jboss-as-standalone"
          execute :sudo, "rm #{fetch(:jboss_as_conf_path)}"
          # execute :sudo, "rm #{fetch(:jboss_home)}/standalone/configuration/#{fetch(:jboss_config)}"
        # execute :sudo, "update-rc.d -f jboss-as-standalone defaults"

        when 'binscripts'
          raise 'not implemenets'
        when 'runit'
          raise 'not implemenets'
        when 'upstart'
          execute :sudo, "rm #{fetch(:jboss_upstart_script)}"
      end
    end
  end
end

namespace :torquebox do
  desc "Start TorqueBox Server"
  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      cap_info "Starting TorqueBox AS"

      case fetch(:jboss_control_style)
        when 'initd'
          execute "#{fetch(:jboss_init_script)} start"
        when 'binscripts'
          execute :sudo, "nohup #{fetch(:jboss_home)}/bin/standalone.sh -b #{fetch(:jboss_bind_address)} < /dev/null > /dev/null 2>&1 &"
        when 'runit'
          execute :sudo, "sv start torquebox"
        when 'upstart'
          execute :sudo, "service torquebox start"
      end
    end
  end

  task :force_stop do
    on roles(:app), in: :sequence, wait: 5 do
      cap_info "Force stop torqubox as"
      cap_info "********* Stopping JBoss Server by killing the process **********";
      execute "ps -e | grep jboss | grep -v grep | awk '{print $1}' | xargs killall"
      cap_info "********* Stopped JBoss Server by killing the process **********";
    end
  end

  desc 'touch dodeploy'
  task :do_deploy do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, "#{fetch(:jboss_home)}/standalone/deployments/#{fetch(:torquebox_app_name, fetch(:application))}-knob.yml.dodeploy"
    end
  end

  desc "Hot-restart the server"
  task :hot_restart, [:target] do |t, args|
    on roles(:app), in: :sequence, wait: 5 do
      within current_path do
          execute :touch, "tmp/restart-#{args[:target]}.txt"
      end
    end
  end

  desc "Stop TorqueBox Server"
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      cap_info "Stopping TorqueBox AS"

      case fetch(:jboss_control_style)
        when 'initd'
          execute :sudo, "JBOSS_HOME=#{fetch(:jboss_home)} #{fetch(:jboss_init_script)} stop"
        when 'binscripts'
          execute :sudo, "#{fetch(:jboss_home)}/bin/jboss-cli.sh --connect :shutdown"
        when 'runit'
          execute :sudo, "sv stop torquebox"
        when 'upstart'
          execute :sudo, "service torquebox stop"
      end
    end
  end

  desc "Restart TorqueBox Server"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      case ( fetch(:jboss_control_style) )
        when 'initd'
          cap_info    "Restarting TorqueBox AS"
          execute :sudo, "JBOSS_HOME=#{fetch(:jboss_home)} #{fetch(:jboss_init_script)} restart"
        when 'binscripts'
          execute :sudo, "#{fetch(:jboss_home)}/bin/jboss-cli.sh --connect :shutdown"
          execute :sudo, "nohup #{fetch(:jboss_home)}/bin/standalone.sh -bpublic=#{fetch(:jboss_bind_address)} < /dev/null > /dev/null 2>&1 &"
        when 'runit'
          cap_info    "Restarting TorqueBox AS"
          execute :sudo, "sv restart torquebox"
        when 'upstart'
          cap_info    "Restarting TorqueBox AS"
          execute :sudo, "service torquebox restart"
      end
    end
  end

  task :info do
    on roles(:app), in: :sequence, wait: 5 do
      cap_info "torquebox_home........#{fetch(:torquebox_home)}"
      cap_info "jboss_home............#{fetch(:jboss_home)}"
      cap_info "jboss_init_script.....#{fetch(:jboss_init_script)}"
      cap_info "jruby_home............#{fetch(:jruby_home)}"
      cap_info "bundle command........#{fetch(:bundle_cmd)}"
      cap_info "knob.yml.............."
      puts YAML.dump(create_deployment_descriptor(current_path))
    end
  end

  task :check do
    puts "style #{fetch(:jboss_control_style)}"

    on roles(:app), in: :sequence, wait: 5 do
      case fetch(:jboss_control_style)
        when 'initd'
          execute "test -x #{fetch(:jboss_init_script)}"
        when 'runit'
          execute "test -x #{fetch(:jboss_runit_script)}"
        when 'upstart'
          test "[[ -f #{fetch(:jboss_upstart_script)} ]]"
      end

      execute "test -d #{fetch(:jboss_home)}"

      unless %w[initd binscripts runit upstart].include?(fetch(:jboss_control_style))
        error "invalid fetch(:jboss_control_style): #{fetch(:jboss_control_style)}"
      end
    end
  end

  task :deployment_descriptor do
    cap_info "creating deployment descriptor"

    # dd_str  = YAML.dump_stream(create_deployment_descriptor(release_path))
    dd_str  = YAML.dump_stream(create_deployment_descriptor(current_path))
    dd_file = "#{fetch(:jboss_home)}/standalone/deployments/#{fetch(:torquebox_app_name, fetch(:application))}-knob.yml"

    on roles(:app), in: :sequence, wait: 5 do
      dd_io   = StringIO.new(dd_str)
      upload!(dd_io, dd_file)
    end
  end

  task :rollback_deployment_descriptor do
    cap_info "rolling back deployment descriptor"

    dd_str  = YAML.dump_stream(create_deployment_descriptor(previous_release))
    dd_file = "#{fetch(:jboss_home)}/standalone/deployments/#{fetch(:application)}-knob.yml"

    on roles(:app), in: :sequence, wait: 5 do
      dd_io   = StringIO.new(dd_str)
      upload!(dd_io, dd_file)
    end
  end

  desc "Dump the deployment descriptor"
  task :dump do
    on roles(:app), in: :sequence, wait: 5 do
      dd = create_deployment_descriptor(current_path)
      cap_info dd
      exit
      puts YAML.dump(create_deployment_descriptor(current_path))
    end
  end
end

# namespace :deploy do
#   desc "Restart Application"
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       execute "touch #{fetch(:jboss_home)}/standalone/deployments/#{fetch(:torquebox_app_name, fetch(:application))}-knob.yml.dodeploy"
#     end
#   end
# end

before 'deploy:check',             'torquebox:check'
after  'deploy:symlink:shared',    'torquebox:deployment_descriptor'
after  'deploy:rollback',          'torquebox:rollback_deployment_descriptor'
