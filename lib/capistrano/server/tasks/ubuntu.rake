namespace :ubuntu do
  desc "Install common things"
  task :install do
    invoke 'ubuntu:repo'
    on roles(:all) do
      execute 'export DEBIAN_FRONTEND=noninteractive'
      execute :sudo, "apt-get -yqq update"
      execute :sudo, "apt-get -yqq install software-properties-common"
      execute :sudo, "apt-get -yqq install python-software-properties"
    end
  end

  desc "Configure Server Default"
  task :setup do
    invoke 'ubuntu:sudo_user'
    invoke 'ubuntu:locale'
    invoke 'ubuntu:build'
  end

  desc "Set user group in sudo to make easy to install"
  task :sudo_user do
    on roles(:all), in: :parallel do |host|
      user = fetch(:user)
      #password = ask("#{user}'s password : ", nil )
      #execute :sudo, "adduser #{user} --disabled-password"
      execute :sudo, "usermod -a -G sudo #{user}"
      execute :sudo, "cp /etc/sudoers /etc/sudoers.bak"
      execute :sudo, "cat /etc/sudoers > ~/x19fhsgud98fys7d"
      execute :sudo, "echo '#{user} ALL=(ALL) NOPASSWD:ALL' >> ~/x19fhsgud98fys7d"
      execute :sudo, "chown root:root ~/x19fhsgud98fys7d"
      execute :sudo, "chmod 0440 ~/x19fhsgud98fys7d"
      execute :sudo, "mv ~/x19fhsgud98fys7d /etc/sudoers"
    end
  end

  desc 'Change repository to ftp.daum.net'
  task :repo do
    on roles(:all), in: :parallel do |host|

      #version 12.10
      #execute :sudo, "sed -i 's/kr.archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list"
      #execute :sudo, "sed -i 's/us.archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list"

      #version 13.10
      # execute :sudo, "sed -i 's/archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list"
      # execute :sudo, "sed -i 's/security.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list"
      # execute :sudo, "apt-get -y update"
    end
  end

  desc "Set enUS.UTF-8"
  task :locale do
    on roles(:all), in: :parallel do |host|
      execute :sudo, "locale-gen en_US.UTF-8"
      execute :echo, 'LC_ALL="en_US.UTF-8" >> /tmp/set_locale'
      execute :echo, 'LANGUAGE="en_US.UTF-8" >> /tmp/set_locale'
      execute :cat, "/tmp/set_locale /etc/environment > /tmp/environment.tmp"
      execute :sudo, "mv /tmp/environment.tmp /etc/environment"
      execute :locale
    end
  end

  task :build do
    on roles(:all), in: :parallel do |host|
      execute 'export DEBIAN_FRONTEND=noninteractive'
      execute :sudo, "apt-get -yqq install linux-headers-server build-essential zip unzip"
      # execute :sudo, "apt-get -y install clamav*"
    end
  end
end
