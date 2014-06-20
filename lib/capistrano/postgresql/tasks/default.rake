namespace :load do
  task :defaults do

    set :postgresql_adapter, "jdbcpostgresql"
    set :postgresql_host, "localhost"
    set :postgresql_encording, "utf8"
    set :postgresql_pool, 64
    set :postgresql_user, -> { fetch(:application) }
    set :postgresql_port, 5432

    set :postgresql_password, -> { ask "PostgreSQL Password:", fetch(:rails_env) }
    set :postgresql_database, -> { "#{fetch(:application)}_#{fetch(:rails_env)}" }
    set :postgresql_dump_path, -> { "#{current_path}/tmp" }
    set :postgresql_dump_file, -> { "#{fetch(:application)}_dump.sql" }
    set :postgresql_local_dump_path, -> { File.expand_path("../../../tmp", __FILE__) }
    set :postgresql_install_path, -> { "/etc/postgresql/9.3/main" }

    set :pg_hba_conf, "pg_hba-9.3.conf.erb"
    set :pg_conf, "postgresql-9.3.conf.erb"
    set :database_conf, "postgresql.yml.erb"
  end
end
