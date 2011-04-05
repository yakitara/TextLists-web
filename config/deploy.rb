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
# set :shared_tmp, true # for my patch of capistrano
# raise "Use `bundle exec cap`!" unless shared_children.include?("tmp")

task "jerle" do
  server "jerle.yakitara.com", :app, :web, :db, :primary => true
  set :deploy_to, "/var/www/textlists"
  set :rvm_ruby_string, 'ruby-1.9.2-head' # Or whatever env you want it to run in.
  set :repository, "/var/www/git/textlists.git"
end

task "jerle.8080" do
  server "jerle.yakitara.com", :app, :web, :db, :primary => true
  set :deploy_to, "/var/www/textlists.8080"
  set :rvm_ruby_string, 'ruby-1.9.2-p180' # Or whatever env you want it to run in.
  set :repository, "/var/www/git/textlists.git"
  set :branch, "TextLists2"
  set :rvm_bin_path, "/usr/local/bin"
  set :passenger_standalone, {:port => 8080}
end

# task "silent" do
#   server "silent.yakitara.com", :app, :web, :db, :primary => true
#   set :deploy_to, "/var/www/items"
# end

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
  def port_opt(port)
    port ? "--port #{port}" : nil
  end

  def pid_file_opt(port = 3000)
    "--pid-file " + File.join(current_path,"tmp","pids","passenger.#{port}.pid")
  end

  def log_file_opt(port = 3000)
    "--log-file " + File.join(current_path,"log","passenger.#{port}.log")
  end

  task :start do
    if opts = passenger_standalone
      port = opts[:port]
      run "passenger start -d -e production #{port_opt(port)} #{pid_file_opt(port)} #{log_file_opt(port)} #{current_path}"
    end
  end
  task :stop do
    if opts = passenger_standalone
      run "passenger stop #{pid_file_opt(opts[:port])}"
    end
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  task :status do
    if opts = passenger_standalone
      run "passenger status #{pid_file_opt(opts[:port])}"
    end
    run "passenger-status"
  end
end

desc "copy secret initializers"
task :copy_initializers do
  run "cp #{shared_path}/config/initializers/*.rb #{latest_release}/config/initializers/ || exit 0"
end
after "deploy:update_code", "copy_initializers"

task :foo do
#  p shared_children
#  p shared_tmp
#  set :shared_tmp, true
#  p shared_tmp
#  p shared_children
  # set :shared_children, shared_children.push("tmp").uniq
  # p shared_children
end
