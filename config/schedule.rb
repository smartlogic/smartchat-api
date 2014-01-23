job_type :nice_rake, "cd :path && RAILS_ENV=:environment /usr/bin/nice bundle exec rake :task --silent :output"

every :day do
  nice_rake 'clean_up:media_store'
end
