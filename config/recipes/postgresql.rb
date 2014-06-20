set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_#{rails_env}" }
set_default(:postgresql_dump_path) { "#{current_path}/tmp" }
set_default(:postgresql_dump_file) { "#{application}_dump.sql" }
set_default(:postgresql_local_dump_path) { File.expand_path("../../../tmp", __FILE__) }
set_default(:postgresql_path) { "/etc/postgresql/9.2/main" }

namespace :postgresql do
  desc "Install the latest stable release of PostgreSQL."
  task :install_pg, roles: :db, only: {primary: true} do
    run "#{sudo} apt-get -y install postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2"
  end

  task :install_libpg, roles: :app do
    run "#{sudo} apt-get -y install libpq-dev"
  end

  task :install, roles: [:db, :app] do
    run "#{sudo} add-apt-repository ppa:pitti/postgresql", pty: true do |ch, stream, data|
      press_enter( ch, stream, data)
    end
    run "#{sudo} apt-get -y update"
    install_pg
    install_libpg
  end
  after "deploy:install", "postgresql:install"

  desc "Create a Role for this application."
  task :create_role, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
    set_superuser
  end

  task :set_superuser, roles: :db do
    run %Q{#{sudo} -u postgres psql -c "ALTER ROLE #{postgresql_user} SUPERUSER;"}
  end

  desc "Delete a Role for this application."
  task :delete_role, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "drop user #{postgresql_user};"}
  end

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  end
  after "deploy:setup", "postgresql:create_role"
  after "deploy:setup", "postgresql:create_database"


  desc "Drop a database for this application."
  task :drop_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "drop database #{postgresql_database};"}
  end
  before "db:reset", "postgresql:drop_database"
  before "db:reset", "postgresql:create_database"


  desc "Generate the database.yml configuration file."
  task :setup do
    config_pg_hba
    config_postgresql_conf
    config_database
  end
  after "deploy:setup", "postgresql:setup"

  desc "Set pg_hba.conf"
  task :config_pg_hba, roles: :db, only: {primary: true} do
    template "pg_hba.conf.erb", "/tmp/pg_hba.conf"
    run "#{sudo} mv /tmp/pg_hba.conf #{postgresql_path}/pg_hba.conf"
  end

  desc "Set postgresql.conf"
  task :config_postgresql_conf, roles: :db, only: {primary: true} do
    template "postgresql.conf.erb", "/tmp/postgresql.conf"
    run "#{sudo} mv /tmp/postgresql.conf #{postgresql_path}/postgresql.conf"
  end

  desc "config database.yml"
  task :config_database, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end


  %w[start stop restart].each do |command|
    desc "#{command} postgresql"
    task command, roles: :db do
      run "#{sudo} service postgresql #{command}"
    end
    #after "deploy:#{command}", "redis:#{command}"
  end

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "postgresql:symlink"

  desc "database console"
  task :console, roles: :db do
    auth = capture "cat #{shared_path}/config/database.yml"
    pass = auth.match(/password: (.*$)/).captures.first
    hostname = find_servers_for_task(current_task).first
    commands = "psql -u #{postgresql_user} #{postgresql_database}'"
    # run "psql -U #{application} #{postgresql_database}"
    run commands do |ch, stream, data|
      if data =~ /Password for user/
        ch.send_data("#{pass}\n")
      end
    end

  end


  namespace :local do
    desc "Download remote database to tmp/"
    task :download do
      dumpfile = "#{postgresql_local_dump_path}/#{postgresql_dump_file}.gz"
      get "#{postgresql_dump_path}/#{postgresql_dump_file}.gz", dumpfile
    end

    desc "Restores local database from temp file"
    task :restore do
      auth = YAML.load_file(File.expand_path('../../database.yml', __FILE__))
      dev  = auth['development']
      user, pass, database, host = dev['username'], dev['password'], dev['database'], dev['host']
      dumpfile = "#{postgresql_local_dump_path}/#{postgresql_dump_file}"
      #system "gzip -cd #{dumpfile}.gz > #{dumpfile} && cat #{dumpfile} | psql -U #{user} -h #{host} #{database}"
      system "gzip -cd #{dumpfile}.gz > #{dumpfile} && pg_restore -c  -v -h #{host} -U #{user}  -d #{database} #{dumpfile}"
    end

    desc "Dump remote database and download it locally"
    task :localize do
      remote.dump
      download
    end

    desc "Dump remote database, download it locally and restore local database"
    task :sync do
      localize
      restore
    end
  end

  namespace :remote do
    desc "Dump remote database"
    task :dump do
      dbyml = capture "cat #{shared_path}/config/database.yml"
      info  = YAML.load dbyml
      puts "#{stage}"
      db    = info[fetch(:rails_env).to_s]
      user, pass, database, host = db['username'], db['password'], db['database'], db['host']
      commands = <<-CMD
        pg_dump -U #{user} -h #{host} -Fc #{database} | \
        gzip > #{postgresql_dump_path}/#{postgresql_dump_file}.gz
      CMD
      run commands do |ch, stream, data|
        if data =~ /Password/
          ch.send_data("#{pass}\n")
        end
      end
    end

    # desc "Uploads local sql.gz file to remote server"
    # task :upload do
    #   dumpfile = "#{postgresql_local_dump_path}/#{postgresql_dump_file}.gz"
    #   upfile   = "#{postgresql_dump_path}/#{postgresql_dump_file}.gz"
    #   put File.read(dumpfile), upfile
    # end

    # desc "Restores remote database"
    # task :restore do
    #   dumpfile = "#{postgresql_dump_path}/#{postgresql_dump_file}"
    #   gzfile   = "#{dumpfile}.gz"
    #   dbyml    = capture "cat #{shared_path}/config/database.yml"
    #   info     = YAML.load dbyml
    #   db       = info['production']
    #   user, pass, database, host = db['username'], db['password'], db['database'], db['host']
    #   commands = <<-CMD
    #     gzip -cd #{dumpfile}.gz > #{dumpfile} && pg_restore -c -v -h #{host} -U #{user} -d #{database} #{dumpfile}
    #   CMD
    #   run commands do |ch, stream, data|
    #     if data =~ /Password/
    #       ch.send_data("#{pass}\n")
    #     end
    #   end
    # end

    # desc "Uploads and restores remote database"
    # task :sync do
    #   upload
    #   restore
    # end
  end

  #desc "Symlink the database.yml file into latest release"
  #task :symlink, roles: :app do
  #  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  #end
  #after "deploy:finalize_update", "postgresql:symlink"
end
