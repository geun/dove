namespace :ntp do
  task :install do
    on roles(:all), in: :parallel do
      execute :sudo, "update-rc.d -f ntpdate remove"
      execute :sudo, "apt-get -y update"
      execute :sudo, "apt-get -y install ntp"
      # execute :sudo, "cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local"
    end
  end
end