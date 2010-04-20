# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
if RUBY_VERSION != "1.9.2"
   raise "use rake with ruby1.9.2 (maybe rake1.9)"
end

require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

# load "/usr/local/rvm/gems/ruby-1.9.2-head/gems/ar_fixtures-0.0.4/tasks/ar_fixtures.rake"
# require "yaml_waml"

Rails::Application.load_tasks
