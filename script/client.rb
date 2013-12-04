ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment',  __FILE__)
require 'capybara'
require 'capybara/server'
require 'database_cleaner'
require 'faraday'

DatabaseCleaner.strategy = :truncation

Capybara.server do |app, port|
  require 'rack/handler/thin'
  Thin::Logging.silent = true
  Rack::Handler::Thin.run(app, :Port => port)
end

server = Capybara::Server.new(Rails.application, 8888)
server.boot

puts "Server booted"

begin
  class Middleware < Faraday::Middleware
    def call(env)
      env[:request_headers]["Content-Type"] = "application/json"
      env[:request_headers]["Accept"] = "application/json"

      @app.call(env)
    end
  end

  client = Faraday.new(:url => "http://localhost:8888") do |f|
    f.use Middleware
    f.adapter Faraday.default_adapter
  end

  response_body = JSON.parse(client.get("/").body)
  registration_link = response_body["_links"]["smartchat:register-user"]["href"]

  response = client.post(registration_link, {
    :user => {
      :email => "eric@example.com",
      :password => "password",
      :phone => "123-123-1234"
    }
  }.to_json)

  response_body = JSON.parse(response.body)

  private_key = OpenSSL::PKey::RSA.new(response_body["private_key"], User.hash_password_for_private_key("password"))

  puts "Registered"
ensure
  DatabaseCleaner.clean
end
