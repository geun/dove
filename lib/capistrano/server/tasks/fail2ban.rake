namespace :fail2ban do

  desc "Install fail2ban"
  task :install do
    on roles(:all) do
      execute :sudo, "apt-get -y update"
      execute :sudo, "apt-get -y install fail2ban"
      execute :sudo, "sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local"
    end
  end

  %w[start stop restart].each do |command|
    desc "#{command} fail2ban"
    task command do
      on roles(:all) do
        execute :sudo, "service nginx #{command}"
      end
    end
  end

end

