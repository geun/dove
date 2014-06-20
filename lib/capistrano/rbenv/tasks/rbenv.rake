namespace :load do
  task :defaults do
    set :rbenv_bootstrap, "bootstrap-ubuntu-12-04"
  end
end

namespace :rbenv do
  desc "Install rbenv, Ruby, and the Bundler gem"
  task :install do
    on roles(:all) do
      execute :sudo, %w(apt-get -y install curl git-core)
      execute :sudo, "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"

      bashrc = StringIO.new <<-BASHRC
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
      BASHRC
      upload! bashrc, "/tmp/rbenvrc"
      execute "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
      execute "mv ~/.bashrc.tmp ~/.bashrc"
      execute %q{export PATH="$HOME/.rbenv/bin:$PATH"}
      execute %q{eval "$(rbenv init -)"}
      execute "rbenv #{fetch(:rbenv_bootstrap)}"
      execute "rbenv install #{fetch(:rbenv_ruby)}"
      execute "rbenv global #{fetch(:rbenv_ruby)}"
      execute "gem install bundler --no-ri --no-rdoc"
      #run "gem install bundler --no-ri --no-rdoc"
      execute "rbenv rehash"
    end
  end

  #after "deploy:install", "rbenv:install"


  desc "rehash rbenv"
  task :rehash do
    on roles(:all)  do
      execute :rbenv, "rehash"
    end
  end
end

# namespace :rbenv do
#   task :validate do
#     on roles(fetch(:rbenv_roles)) do
#       rbenv_ruby = fetch(:rbenv_ruby)
#       if rbenv_ruby.nil?
#         error "rbenv: rbenv_ruby is not set"
#         exit 1
#       end
#
#       if test "[ ! -d #{fetch(:rbenv_ruby_dir)} ]"
#         error "rbenv: #{rbenv_ruby} is not installed or not found in #{fetch(:rbenv_ruby_dir)}"
#         exit 1
#       end
#     end
#   end
#
#   task :map_bins do
#     SSHKit.config.default_env.merge!({ rbenv_root: fetch(:rbenv_path), rbenv_version: fetch(:rbenv_ruby) })
#     rbenv_prefix = fetch(:rbenv_prefix, proc { "#{fetch(:rbenv_path)}/bin/rbenv exec" })
#     SSHKit.config.command_map[:rbenv] = "#{fetch(:rbenv_path)}/bin/rbenv"
#
#     fetch(:rbenv_map_bins).each do |command|
#       SSHKit.config.command_map.prefix[command.to_sym].unshift(rbenv_prefix)
#     end
#   end
# end
#
# Capistrano::DSL.stages.each do |stage|
#   #after stage, 'rbenv:validate'
#   after stage, 'rbenv:map_bins'
# end
#
# namespace :load do
#   task :defaults do
#     set :rbenv_path, -> {
#       rbenv_path = fetch(:rbenv_custom_path)
#       rbenv_path ||= if fetch(:rbenv_type, :user) == :system
#                        "/usr/local/rbenv"
#                      else
#                        "~/.rbenv"
#                      end
#     }
#
#     set :rbenv_roles, fetch(:rbenv_roles, :all)
#
#     set :rbenv_ruby_dir, -> { "#{fetch(:rbenv_path)}/versions/#{fetch(:rbenv_ruby)}" }
#     set :rbenv_map_bins, %w{rake gem bundle ruby rails}
#
#     set :rbenv_type, :user # or :system, depends on your rbenv setup
#     set :rbenv_ruby, '2.0.0-p247'
#     set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
#     set :rbenv_map_bins, %w{rake gem bundle ruby rails}
#     set :rbenv_roles, :all # default value
#     set :rbenv_bootstrap, "bootstrap-ubuntu-12-04"
#
#   end
# end
