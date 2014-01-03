web: bundle exec rails s thin --port $PORT
sidekiq: bundle exec sidekiq -C config/sidekiq.yml
worker: env BUNDLE_GEMFILE=worker/Gemfile bundle exec ./worker/bin/smartchat
