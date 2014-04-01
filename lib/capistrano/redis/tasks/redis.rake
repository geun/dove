namespace :redis do
  desc "Install the latest release of Redis"
  task :install do
     on roles(:redis) do
       execute :sudo, %w(add-apt-repository -y ppa:chris-lea/redis-server)
       execute :sudo, %w(apt-get -y update)
       execute :sudo, %w(apt-get -y install redis-server)
     end
  end

  #after "deploy:install", "redis:install"

  %w[start stop restart].each do |command|
    desc "#{command} redis"
    task command do
      on roles(:redis) do
        execute :sudo, "service redis-server #{command}"
      end
    end
  end


end