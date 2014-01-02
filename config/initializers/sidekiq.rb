require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |_, password|
  password == ENV["SIDEKIQ_WEB_PASSWORD"]
end
