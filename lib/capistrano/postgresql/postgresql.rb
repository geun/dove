require_relative 'helper'
# require 'capistrano/postgresql/helper'
include Capistarno::Postgresql::Helpers

load File.expand_path("../tasks/default.rake", __FILE__)
load File.expand_path("../tasks/postgresql.rake", __FILE__)

