$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano" # Load RVM's capistrano plugin.
require 'bundler/capistrano'

set :application, "textlists"
#set :repository,  "silent.yakitara.com:/home/shared/git/items.git"
set :scm, :git
set :deploy_via, :remote_cache
set :local_repository,  "."

# server "silent.yakitara.com", :app, :web, :db, :primary => true
# set :deploy_to, "/var/www/items"
set :user, "www-data"
set :group, "www-data"
set :use_sudo, false

task "jerle" do
  server "jerle.yakitara.com", :app, :web, :db, :primary => true
  set :deploy_to, "/var/www/textlists"
  set :rvm_ruby_string, 'ruby-1.9.2-p180' # Or whatever env you want it to run in.
  set :repository,  "/var/www/git/textlists.git"
end

task "silent" do
  server "silent.yakitara.com", :app, :web, :db, :primary => true
  set :deploy_to, "/var/www/items"
end

namespace :deploy do
  desc "change group of setuped directory"
  task :setup_change_group do
    run "chown -R :#{group} #{deploy_to}"
  end
  after "deploy:setup", "deploy:setup_change_group"

  desc "change group of deployed directory"
  task :change_group do
    run "chown -R :#{group} #{latest_release}"
  end
  after "deploy:finalize_update", "deploy:change_group"
end

# for passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "copy secret initializers"
task :copy_initializers do
  run "cp #{shared_path}/config/initializers/*.rb #{latest_release}/config/initializers/ || exit 0"
end
after "deploy:update_code", "copy_initializers"
