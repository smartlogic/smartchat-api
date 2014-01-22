source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.2'

gem 'active_model_serializers', '~> 0.8.0'
gem 'aws-sdk', '~> 1.0'
gem 'bcrypt-ruby'
gem 'faraday'
gem 'pg'
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'unf'
gem 'values'

group :staging, :production do
  gem 'unicorn'
end

group :development do
  gem 'foreman'
  gem 'capistrano', '~> 2.15.5'
end

group :development, :test do
  gem 'pry-rails'
  gem 'redis-namespace'
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
