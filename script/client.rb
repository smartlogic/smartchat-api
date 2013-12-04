ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment',  __FILE__)
require 'capybara'
require 'capybara/server'
require 'database_cleaner'
require 'faraday'
require 'uri_template'

DatabaseCleaner.strategy = :truncation

Capybara.server do |app, port|
  require 'rack/handler/thin'
  Thin::Logging.silent = true
  Rack::Handler::Thin.run(app, :Port => port)
end

server = Capybara::Server.new(Rails.application, 8888)
server.boot

ActionController::Base.default_url_options = { :host => "localhost:8888" }

puts "Server booted"

begin
  class Middleware < Faraday::Middleware
    def call(env)
      env[:request_headers]["Content-Type"] = "application/json"
      env[:request_headers]["Accept"] = "application/json"

      @app.call(env)
    end
  end

  UserService.create({
    :email => "other@example.com",
    :password => "password",
    :phone => "123-123-1234"
  })

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

  def sign_url(private_key, url)
    digest = OpenSSL::Digest::SHA256.new
    Base64.encode64(private_key.sign(digest, url))
  end

  puts "Registered"

  client.basic_auth("eric@example.com", sign_url(private_key, "http://localhost:8888/"))

  response = client.get("http://localhost:8888/")

  raise "Not authorized" unless response.status < 400

  response_body = JSON.parse(response.body)

  friends_url = response_body["_links"]["smartchat:friends"]["href"]
  client.basic_auth("eric@example.com", sign_url(private_key, friends_url))
  response = client.get(friends_url)

  response_body = JSON.parse(response.body)

  puts "Searching for other@example.com"

  search_url = URITemplate.new(response_body["_links"]["search"]["href"]).expand(:email => "other@example.com")
  client.basic_auth("eric@example.com", sign_url(private_key, search_url))
  response = client.post(search_url)

  response_body = JSON.parse(response.body)

  puts "Found the following friends:"
  response_body["_embedded"]["friends"].each do |friend|
    puts friend["email"]
  end
ensure
  DatabaseCleaner.clean
end
