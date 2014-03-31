require 'capistrano/dove/base'
require 'capistrano/nginx/nginx'
load File.expand_path("../tasks/bootstrap.rake", __FILE__)

module Capistrano
  module TaskEnhancements
    def default_tasks
      %w{install bootstrap:initialize}
    end
  end
end




