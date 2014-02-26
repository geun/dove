#set_default :ruby_version, "1.9.3-p125"
#set_default :rbenv_bootstrap, "bootstrap-ubuntu-12-04"
#
#namespace :rbenv do
#  desc "Install rbenv, Ruby, and the Bundler gem"
#  task :install, roles: :app do
#    run "#{sudo} apt-get -y install curl git-core"
#    run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
#    bashrc = <<-BASHRC
#if [ -d $HOME/.rbenv ]; then
#  export PATH="$HOME/.rbenv/bin:$PATH"
#  eval "$(rbenv init -)"
#fi
#    BASHRC
#    put bashrc, "/tmp/rbenvrc"
#    run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
#    run "mv ~/.bashrc.tmp ~/.bashrc"
#    run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
#    run %q{eval "$(rbenv init -)"}
#    run "rbenv #{rbenv_bootstrap}"
#    run "rbenv install #{ruby_version}"
#    run "rbenv global #{ruby_version}"
#    run "gem install bundler --no-ri --no-rdoc"
#    run "rbenv rehash"
#  end
#  after "deploy:install", "rbenv:install"
#end
#
#
#nam

namespace :ubuntu do
  desc "Configure Server Default"


  task :setup do

  end

  task :group do
    desc "Set user group in sudo to make easy to install"
    run "#{sudo} usermod -a -G sudo #{user}"
    run "#{sudo} cp /etc/sudoers /etc/sudoers.bak"
    run "#{sudo} cat /etc/sudoers > ~/x19fhsgud98fys7d"
    run "#{sudo} echo '#{user} ALL=(ALL) NOPASSWD:ALL' >> ~/x19fhsgud98fys7d"
    run "#{sudo} chown root:root ~/x19fhsgud98fys7d"
    run "#{sudo} chmod 0440 ~/x19fhsgud98fys7d"
    run "#{sudo} mv ~/x19fhsgud98fys7d /etc/sudoers"

    #run "#{sudo} chmod u+w /etc/sudoers"
    #run "#{sudo} echo -S '#{user} ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
    #run "#{sudo} chmod u-w /etc/sudoers"
  end
  after "ubuntu:setup", "ubuntu:group"

  task :repo do
    desc 'change ftp.daum.net'
    run "#{sudo} sed -i 's/kr.archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list"
    run "#{sudo} sed -i 's/us.archive.ubuntu.com/ftp.daum.net/g' /etc/apt/sources.list"
    run "#{sudo} apt-get -y update"
  end
  after "ubuntu:setup", "ubuntu:repo"

  task :locale do
    desc "Set enUS.UTF-8"
    run "#{sudo} locale-gen en_US.UTF-8"
    locale = <<-BASHRC
LC_ALL="en_US.UTF-8"
LANGUAGE="en_US.UTF-8"
    BASHRC
    put locale, "/tmp/set_locale"
    run "cat /tmp/set_locale /etc/environment > /tmp/environment.tmp"
    run "#{sudo} mv /tmp/environment.tmp /etc/environment"
    run "locale"
  end
  after "ubuntu:setup", "ubuntu:locale"

  task :build do
    run "#{sudo} apt-get install linux-headers-server build-essential", pty: true do |ch, stream, data|
      press_yes( ch, stream, data)
    end
  end
  after "ubuntu:setup", "ubuntu:build"


end