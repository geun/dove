namespace :utils do
  desc 'server uptime'
  task :uptime do |host|
    on roles(:all), in: :parallel do
      uptime  = capture(:uptime)
      cap_info "#{host.hostname} reports : #{uptime}"
    end
  end
end