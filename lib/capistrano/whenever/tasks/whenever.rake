namespace :whenever do

  desc 'Show crontab'
  task :show_crontab do
    on roles(:whenever) do
      execute :sudo, "crontab -l -u #{fetch(:user)}"
    end
  end

end


