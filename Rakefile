# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Smartchat::Application.load_tasks

namespace :client do
  task :test do
    puts "Running client script."
    puts "bundle exec ruby script/client.rb"
    system 'bundle exec ruby script/client.rb'
  end
end

task :default => "client:test"
