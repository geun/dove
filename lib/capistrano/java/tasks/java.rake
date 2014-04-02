

namespace :java do

  desc "Install latest stable release of java"
  task :install do

    on roles([:elasticsearch, :logstash_indexer]) do
      #ls /usr/local/jdk
      #if test("[ -]")
      #execute  :sudo, "apt-add-repository", "ppa:webup8team/jaj"
      execute "sudo apt-add-repository -y ppa:webupd8team/java"
      execute "sudo apt-get -y update"
      execute "echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections"
      execute "echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections"
      # sudo echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
      execute "sudo apt-get -y install oracle-java7-installer"
      execute "sudo apt-get install oracle-java7-set-default"
      execute "sudo update-java-alternatives -s java-7-oracle"
      execute "java -version"
    end
  end

end