# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
if RUBY_VERSION != "1.9.2"
   raise "use rake with ruby1.9.2 (maybe rake1.9)"
end

require File.expand_path('../config/application', __FILE__)

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

# load tasks from gems
Bundler.require(:tasks)
def load_task(task_file)
  load Dir[Bundler.bundle_path + "gems/*/{tasks,rails/tasks,lib/tasks}/#{task_file}.rake"].first
end
load_task "ar_fixtures"

Rails::Application.load_tasks
