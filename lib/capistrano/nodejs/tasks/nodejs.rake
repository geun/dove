namespace :nodejs do
  desc "Install the latest relase of Node.js"
  task :install do
    on roles(:app) do
      execute :sudo, %w(add-apt-repository -y ppa:chris-lea/node.js)
      execute :sudo, %w(apt-get -y update)
      execute :sudo, %w(apt-get -y install nodejs)
    end
  end
end
