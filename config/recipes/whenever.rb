namespace :whenever do
  desc "Setup whenever initializer and app configuration"

  task :install, roles: :whenever do
    run "gem install whenever --no-ri --no-rdoc"
    run "rbenv rehash"
  end
  after "deploy:install", "whenever:install"

  task :show, roles: :whenever do

    #args = {
    #    :command => fetch(:whenever_command),
    #    :flags   => fetch(:whenever_clear_flags),
    #    :path    => fetch(:latest_release)
    #}
    #
    #whenever_run_commands(args)

    #run "cd #{current_path} && rbenv exec #{} db:migrate:reset RAILS_ENV=#{rails_env}"
    run "crontab -l"
  end
end
