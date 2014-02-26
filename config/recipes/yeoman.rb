namespace :yeoman do
  desc "Install the latest relase of Node.js"
  task :install, roles: :app do

    #run "#{sudo} add-apt-repository ppa:chris-lea/node.js"
    run "#{sudo} npm install -g yo"
  end
  after "deploy:install", "yeoman:install"

  task :setup, roles: :web do
    template "nginx_yeoman.erb", "/tmp/nginx_#{application}_yeoman" #with faye websocket
    run "#{sudo} mv /tmp/nginx_#{application}_yeoman /etc/nginx/sites-enabled/#{application}_angular"
    run "#{sudo} service nginx restart"
  end
  after "deploy:setup", "yeoman:setup"


end
