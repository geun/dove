require_relative 'helper'
# require 'capistrano/postgresql/helper'
include Capistarno::Torquebox::Helpers

load File.expand_path("../tasks/default.rake", __FILE__)
load File.expand_path("../tasks/torquebox.rake", __FILE__)