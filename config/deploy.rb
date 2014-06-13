set :application, 'smartchat'
set :repo_url, 'git@github.com:smartlogic/smartchat-api.git'

set :deploy_to, '/home/deploy/apps/smartchat'
set :scm, :git

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{bin log files tmp/pids}

set :format, :pretty

set :rbenv_type, :system
set :rbenv_ruby, '2.1.1'
set :rbenv_path, '/opt/rbenv'

set :ssh_options, {
  forward_agent: true,
}

namespace :deploy do
  desc 'Restart application'
  task :restart do
    invoke("unicorn:restart")
    invoke("workers:restart")
  end

  desc 'Setup'
  task :setup do
    invoke('deploy:check')
    invoke('custom:database')
    invoke('monit:setup')
    invoke('nginx:setup')
    invoke('unicorn:setup')
  end

  after :finishing, 'deploy:cleanup'
end

after "deploy:symlink:release", "custom:config"
