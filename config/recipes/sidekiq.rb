namespace :sidekiq do
  %w[start stop restart].each do |command|
    desc "#{command} sidekiq"
    task command, roles: :web do
      sudo "monit #{command} sidekiq"
    end
    after "deploy:#{command}", "sidekiq:#{command}"
  end

  desc "prepare sidekiq to shutdown"
  task :quiet, roles: :web do
    run "cd #{current_path} && test -f tmp/pids/sidekiq.pid && bundle exec sidekiqctl quiet tmp/pids/sidekiq.pid || exit 0"
  end
  before "deploy:update_code", "sidekiq:quiet"
end
