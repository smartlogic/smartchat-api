server "smartchat_all", :web, :worker, :scheduler, :app, :db, :primary => true
set :rails_env, 'all'
set :media_workers, 1
