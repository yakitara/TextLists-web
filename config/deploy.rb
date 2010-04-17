set :application, "items"
set :repository,  "silent.yakitara.com:/home/shared/git/items.git"
set :scm, :git
set :deploy_via, :remote_cache

server "silent.yakitara.com", :app, :web, :db, :primary => true
set :deploy_to, "/var/www/items"
set :user, "www-data"
set :group, "www-data"
set :use_sudo, false


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
