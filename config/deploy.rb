require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'whenever/capistrano'

load 'config/recipes/base'
load 'config/recipes/nginx'
load 'config/recipes/unicorn'
load 'config/recipes/monit'
load 'config/recipes/media_worker'
load 'config/recipes/sidekiq'

set :default_environment, {
  'PATH' => "/opt/rbenv/shims:/opt/rbenv/bin:$PATH",
  'RBENV_ROOT' => "/opt/rbenv"
}

set :bundle_flags, "--deployment --quiet --shebang ruby-local-exec"

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

set :whenever_command, "bundle exec whenever"
set :whenever_roles, :scheduler

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
    run "cd #{release_path}/worker && rbenv local 2.0.0-p247"
  end

  desc "Get config from S3"
  task :config, :roles => :app do
    require 'aws-sdk'
    s3 = AWS::S3.new
    bucket = s3.buckets["smartchat-config"]
    object = bucket.objects["#{rails_env}.env"]
    put object.read, "#{current_path}/.env"
    put object.read, "#{current_path}/worker/.env"
  end
end

namespace :workers do
  desc "bundle workers"
  task :bundle, :roles => :worker do
    run "cd #{release_path}/worker && bundle #{bundle_flags} --without development test --path /home/deploy/apps/smartchat/shared/bundle"
  end

  desc "restart workers"
  task :restart, :roles => :worker do
    sudo "monit restart -g worker"
  end
end

after "deploy:setup", "custom:setup"
before 'bundle:install', 'custom:rbenv_version'
after 'bundle:install', 'workers:bundle'
after "deploy:update_code", "custom:symlink"
after "deploy:update", "custom:config"
after "deploy:update", "deploy:cleanup"
after "deploy:restart", "workers:restart"
