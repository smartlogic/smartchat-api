require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |_, password|
  password == AppContainer.config.sidekiq_web_password
end
