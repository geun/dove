namespace :iptables do

  desc 'show iptables '
  task :show, [:options] do |t, args|
    on roles(:all), in: :parallel do
      options = args[:options] ? args[:options] : ''
      execute sudo, "iptables #{options}"
    end
  end

end