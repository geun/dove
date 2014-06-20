namespace :utils do
  desc 'server uptime'
  task :uptime do
    on roles(:all), in: :parallel do |host|
      uptime  = capture(:uptime)
      cap_info "#{host.hostname} reports : #{uptime}"
    end
  end
end