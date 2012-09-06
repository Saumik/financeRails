set :application, "financeRails"
set :repository,  "git@bitbucket.org:mbergman/mbdev-git.git"

set :user, 'mb'
set :scm, :git
set :deploy_via, :remote_cache
set :branch, "master"
set :use_sudo, false
set :deploy_to, "/home/mb/cap/#{application}"

role :web, "financerails.us.to"                          # Your HTTP server, Apache/etc
role :app, "financerails.us.to"

namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
end