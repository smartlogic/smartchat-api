set_default(:postgresql_pid, "/var/run/postgresql/9.1-main.pid")

namespace :monit do
  desc "Setup all Monit configuration"
  task :setup do
    nginx
    #postgresql
    unicorn
    media_worker
    sidekiq
    syntax
    reload
  end
  after "deploy:setup", "monit:setup"

  task(:nginx, roles: :web) { monit_config "nginx" }
  task(:postgresql, roles: :db) { monit_config "postgresql" }
  task(:unicorn, roles: :web) { monit_config "unicorn" }
  task(:media_worker, roles: :worker) { monit_config "media_worker" }
  task(:sidekiq, roles: :web) { monit_config "sidekiq" }

  %w[start stop restart syntax reload].each do |command|
    desc "Run Monit #{command} script"
    task command do
      sudo "service monit #{command}"
    end
  end
end

def monit_config(name, destination = nil)
  destination ||= "/etc/monit/conf.d/#{name}.conf"
  template "monit/#{name}.erb", "/tmp/monit_#{name}"
  sudo "mv /tmp/monit_#{name} #{destination}"
  sudo "chown root #{destination}"
  sudo "chmod 600 #{destination}"
end
