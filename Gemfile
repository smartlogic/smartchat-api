source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

gem 'active_model_serializers', '~> 0.8.0'
gem 'aws-sdk', '~> 1.0'
gem 'bcrypt-ruby'
gem 'dotenv'
gem 'faraday'
gem 'pg'
gem 'raddocs'
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'unf'
gem 'values'
gem 'whenever'

group :staging, :production do
  gem 'unicorn'
end

group :development do
  gem 'foreman'
  gem 'capistrano', '~> 3.0.0', :require => false
  gem 'capistrano-rails',   '~> 1.1', :require => false
  gem 'capistrano-bundler', '~> 1.1', :require => false
  gem 'capistrano-rbenv', '~> 2.0', :require => false
  gem 'net-ssh', '~> 2.7.0'
end

group :development, :test, :all do
  gem 'redis'
  gem 'redis-namespace'
end

group :development, :test do
  gem 'pry-rails'
  gem 'rspec_api_documentation', :github => 'zipmark/rspec_api_documentation'
  gem 'rspec-rails'
  gem 'thin'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'json_spec'
  gem 'uri_template'
end
