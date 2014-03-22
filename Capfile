# Load DSL and Setup Up Stages
require 'capistrano/setup'

# Includes default deployment tasks
require 'capistrano/deploy'

# Includes tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#
# require 'capistrano/rvm'
#require 'capistrano/rbenv'
#require 'capistrano/chruby'
require 'capistrano/bundler'
#require 'capistrano/rails/assets'
#require 'capistrano/rails/migrations'
require "cap-ec2/capistrano"


Dir.glob('lib/capistrano/**/*.rb').each { |r| import r }

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
#Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }


#load 'lib/capistrano/tasks/unicorn.cap'
#load 'lib/capistrano/tasks/check.cap'
import 'lib/capistrano/tasks/ubuntu.cap'
import 'lib/capistrano/tasks/nginx.cap'



