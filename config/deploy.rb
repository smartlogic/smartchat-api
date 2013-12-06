require 'bundler/capistrano'
require 'capistrano/ext/multistage'

load 'config/recipes/base'
load 'config/recipes/nginx'
load 'config/recipes/unicorn'
load 'config/recipes/monit'

set :default_environment, {
  'PATH' => "/opt/rbenv/shims:/opt/rbenv/bin:$PATH",
  'RBENV_ROOT' => "/opt/rbenv"
}

set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

set :use_sudo, false

set :application, "smartchat"
set :repository,  "git@github.com:smartlogic/smartchat-api"

set :deploy_to, '/home/deploy/apps/smartchat'
set :deploy_via, :remote_cache
set :branch, 'master'
set :scm, :git

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :target_os, :ubuntu

set :user, "deploy"

namespace :custom do
  desc "set up database.yml"
  task :setup, :roles => :app do
    template "database.yml.erb", "#{shared_path}/database.yml"
  end

  desc "Symlinks to release"
  task :symlink, :roles => :app do
    run "ln -nfs #{shared_path}/database.yml #{release_path}/config"
  end

  desc 'Create the .rbenv-version file'
  task :rbenv_version, :roles => :app do
    run "cd #{release_path} && rbenv local 2.0.0-p247"
  end
end

after "deploy:setup", "custom:setup"
before 'bundle:install', 'custom:rbenv_version'
after "deploy:update_code", "custom:symlink"
after "deploy:update", "deploy:cleanup"
