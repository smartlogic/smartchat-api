server "smartchat_web", :web, :app, :db, :primary => true
server "smartchat_worker", :worker, :app
set :rails_env, 'staging'
