server "smartchat_web", :web, :app, :db, :primary => true
server "smartchat_worker", :worker, :app
server "smartchat_scheduler", :scheduler, :app
set :rails_env, 'staging'
