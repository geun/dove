namespace :postgresql do
  desc "Install the latest stable release of PostgreSQL."
  task :install do

    invoke 'postgresql:update_repo'

    # http://wiki.postgresql.org/wiki/Apt
    on roles(:db) do |host|
      execute :sudo, 'apt-get update'
      execute :sudo, 'apt-get -y install postgresql-9.3 postgresql-contrib-9.3 postgresql-client-9.3'
    end
    on roles(:app) do |host|
      execute :sudo, 'apt-get update'
      execute :sudo, 'apt-get -y install libpq-dev'
    end
  end

  desc 'Uninstall'
  task :uninstall do
    on roles(:db) do
      execute :sudo, 'apt-get -y --purge remove postgresql-9.3 postgresql-contrib-9.3 postgresql-client-9.3'
    end

  end
  # after "deploy:install", "postgresql:install"

  task :update_repo do
    on roles(:db) do |host|
      execute :sudo, %Q(sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/postgresql.list')
      execute :sudo, %Q(wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -)
    end
  end

  desc "Create a Role for this application."
  task :create_role do
    on roles(:db), only: {primary: true} do
      psql '-c', %Q("create user #{fetch(:postgresql_user)} with password '#{fetch(:postgresql_password)}';")
    end
    invoke 'postgresql:set_superuser'
  end

  task :set_superuser do
    on roles(:db) do
      psql '-c', %Q("ALTER ROLE #{fetch(:postgresql_user)} SUPERUSER;")
    end
  end

  desc "Delete a Role for this application."
  task :delete_role do
    on roles(:db) do
      psql '-c', %Q("drop user #{fetch(:postgresql_user)};")
    end
  end

  desc "Create a database for this application."
  task :create_database do
    on roles(:db) do
      psql '-c', %Q("create database #{fetch(:postgresql_database)} owner #{fetch(:postgresql_user)};")
    end
  end
  # after "deploy:setup", "postgresql:create_role"
  # after "deploy:setup", "postgresql:create_database"

  desc "Drop a database for this application."
  task :drop_database do
    on roles(:db)  do
      psql '-c', %Q(drop database #{fetch(:postgresql_database)};)
    end
  end
  # before "db:reset", "postgresql:drop_database"
  # before "db:reset", "postgresql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup do
    invoke 'postgresql:config_pg_hba'
    invoke 'postgresql:config_postgresql_conf'
    invoke 'postgresql:config_database'
  end
  # after "deploy:setup", "postgresql:setup"

  desc "Set pg_hba.conf"
  task :config_pg_hba do
    on roles(:db) do
      smart_template fetch(:pg_hba_conf), "/tmp/pg_hba.conf"
      execute :sudo, "mv /tmp/pg_hba.conf #{fetch(:postgresql_install_path)}/pg_hba.conf"
      execute :sudo, "chown postgres:postgres #{fetch(:postgresql_install_path)}/pg_hba.conf"
    end
  end

  desc "Set postgresql.conf"
  task :config_postgresql_conf do
    on roles(:db) do
      smart_template fetch(:pg_conf), "/tmp/postgresql.conf"
      execute :sudo, "mv /tmp/postgresql.conf #{fetch(:postgresql_install_path)}/postgresql.conf"
      execute :sudo, "chown postgres:postgres #{fetch(:postgresql_install_path)}/postgresql.conf"
    end
  end

  desc "config database.yml"
  task :config_database do
    password = fetch(:postgresql_password)
    on roles(:app) do
      database_file = shared_path.join('config/database.yml')
      unless test "[ -d #{database_file} ]"
        execute :mkdir, '-pv',  shared_path.join('config')
      end
      smart_template fetch(:database_conf), "/tmp/database.yml"
      execute :sudo, "mv /tmp/database.yml #{database_file}"
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} postgresql"
    task command do
      on roles(:db) do
        execute :sudo, "service postgresql #{command}"
      end
    end
    #after "deploy:#{command}", "redis:#{command}"
  end

  desc "Symlink the database.yml file into latest release"
  task :symlink do
    set :linked_files, fetch(:linked_files, []).push('config/database.yml')
  end
  # after "deploy:finalize_update", "postgresql:symlink"
  after 'deploy:started', 'postgresql:symlink'



  # desc "database console"
  # task :console, roles: :db do
  #   auth = capture "cat #{shared_path}/config/database.yml"
  #   pass = auth.match(/password: (.*$)/).captures.first
  #   hostname = find_servers_for_task(current_task).first
  #   commands = "psql -u #{postgresql_user} #{postgresql_database}'"
  #   # run "psql -U #{application} #{postgresql_database}"
  #   run commands do |ch, stream, data|
  #     if data =~ /Password for user/
  #       ch.send_data("#{pass}\n")
  #     end
  #   end
  #
  # end
  #
  #
  # namespace :local do
  #   desc "Download remote database to tmp/"
  #   task :download do
  #     dumpfile = "#{postgresql_local_dump_path}/#{postgresql_dump_file}.gz"
  #     get "#{postgresql_dump_path}/#{postgresql_dump_file}.gz", dumpfile
  #   end
  #
  #   desc "Restores local database from temp file"
  #   task :restore do
  #     auth = YAML.load_file(File.expand_path('../../database.yml', __FILE__))
  #     dev  = auth['development']
  #     user, pass, database, host = dev['username'], dev['password'], dev['database'], dev['host']
  #     dumpfile = "#{postgresql_local_dump_path}/#{postgresql_dump_file}"
  #     #system "gzip -cd #{dumpfile}.gz > #{dumpfile} && cat #{dumpfile} | psql -U #{user} -h #{host} #{database}"
  #     system "gzip -cd #{dumpfile}.gz > #{dumpfile} && pg_restore -c  -v -h #{host} -U #{user}  -d #{database} #{dumpfile}"
  #   end
  #
  #   desc "Dump remote database and download it locally"
  #   task :localize do
  #     remote.dump
  #     download
  #   end
  #
  #   desc "Dump remote database, download it locally and restore local database"
  #   task :sync do
  #     localize
  #     restore
  #   end
  # end
  #
  # namespace :remote do
  #   desc "Dump remote database"
  #   task :dump do
  #     dbyml = capture "cat #{shared_path}/config/database.yml"
  #     info  = YAML.load dbyml
  #     puts "#{stage}"
  #     db    = info[fetch(:rails_env).to_s]
  #     user, pass, database, host = db['username'], db['password'], db['database'], db['host']
  #     commands = <<-CMD
  #       pg_dump -U #{user} -h #{host} -Fc #{database} | \
  #       gzip > #{postgresql_dump_path}/#{postgresql_dump_file}.gz
  #     CMD
  #     run commands do |ch, stream, data|
  #       if data =~ /Password/
  #         ch.send_data("#{pass}\n")
  #       end
  #     end
  #   end
  #
  #   # desc "Uploads local sql.gz file to remote server"
  #   # task :upload do
  #   #   dumpfile = "#{postgresql_local_dump_path}/#{postgresql_dump_file}.gz"
  #   #   upfile   = "#{postgresql_dump_path}/#{postgresql_dump_file}.gz"
  #   #   put File.read(dumpfile), upfile
  #   # end
  #
  #   # desc "Restores remote database"
  #   # task :restore do
  #   #   dumpfile = "#{postgresql_dump_path}/#{postgresql_dump_file}"
  #   #   gzfile   = "#{dumpfile}.gz"
  #   #   dbyml    = capture "cat #{shared_path}/config/database.yml"
  #   #   info     = YAML.load dbyml
  #   #   db       = info['production']
  #   #   user, pass, database, host = db['username'], db['password'], db['database'], db['host']
  #   #   commands = <<-CMD
  #   #     gzip -cd #{dumpfile}.gz > #{dumpfile} && pg_restore -c -v -h #{host} -U #{user} -d #{database} #{dumpfile}
  #   #   CMD
  #   #   run commands do |ch, stream, data|
  #   #     if data =~ /Password/
  #   #       ch.send_data("#{pass}\n")
  #   #     end
  #   #   end
  #   # end
  #
  #   # desc "Uploads and restores remote database"
  #   # task :sync do
  #   #   upload
  #   #   restore
  #   # end
  # end
  #
  # #desc "Symlink the database.yml file into latest release"
  # #task :symlink, roles: :app do
  # #  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  # #end
  # #after "deploy:finalize_update", "postgresql:symlink"
end
