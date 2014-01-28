ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment',  __FILE__)
require 'capybara'
require 'capybara/server'
require 'database_cleaner'
require 'faraday'
require 'uri_template'
require 'sidekiq/testing'

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

  other = UserService.create({
    :username => "other",
    :email => "other@example.com",
    :password => "password",
  })

  other.create_device(:device_id => "123", :device_type => "android")

  client = Faraday.new(:url => "http://localhost:8888") do |f|
    f.use Middleware
    f.adapter Faraday.default_adapter
  end

  response_body = JSON.parse(client.get("/").body)
  registration_link = response_body["_links"]["smartchat:users"]["href"]

  response = client.post(registration_link, {
    :user => {
      :username => "eric",
      :email => "eric@example.com",
      :password => "password",
    }
  }.to_json)

  response_body = JSON.parse(response.body)

  private_key = OpenSSL::PKey::RSA.new(response_body["private_key"], User.hash_password_for_private_key("password"))

  def sign_url(private_key, url)
    digest = OpenSSL::Digest::SHA256.new
    Base64.encode64(private_key.sign(digest, url))
  end

  puts "Registered"

  client.basic_auth("eric", sign_url(private_key, "http://localhost:8888/"))

  response = client.get("http://localhost:8888/")

  raise "Not authorized" unless response.status < 400

  response_body = JSON.parse(response.body)

  friends_url = response_body["_links"]["smartchat:friends"]["href"]
  client.basic_auth("eric", sign_url(private_key, friends_url))
  response = client.get(friends_url)

  response_body = JSON.parse(response.body)

  puts "Searching for other@example.com"

  search_url = response_body["_links"]["search"]["href"]
  search_url = URITemplate.new(search_url).expand(:emails => [Digest::MD5.hexdigest("other@example.com")])
  p search_url
  client.basic_auth("eric", sign_url(private_key, search_url))
  response = client.post(search_url)

  response_body = JSON.parse(response.body)

  puts "Found the following friends:"
  response_body["_embedded"]["friends"].each do |friend|
    puts "* #{friend["username"]}"
  end

  raise "No friends to add" unless response_body["_embedded"]["friends"].count > 0

  friend = response_body["_embedded"]["friends"].first
  puts "Adding #{friend["username"]}"

  add_friend_url = friend["_links"]["smartchat:add-friend"]["href"]
  client.basic_auth("eric", sign_url(private_key, add_friend_url))
  response = client.post(add_friend_url)

  raise "Failed adding friend" unless response.status == 201

  client.basic_auth("eric", sign_url(private_key, friends_url))
  response = client.get(friends_url)

  response_body = JSON.parse(response.body)

  raise "No friends" unless response_body["_embedded"]["friends"].count > 0

  puts "Your friends"
  friends = response_body["_embedded"]["friends"].each do |friend|
    puts "* #{friend["username"]}"
  end

  puts "Sending a smartchat"

  client.basic_auth("eric", sign_url(private_key, "http://localhost:8888/"))
  response = client.get("http://localhost:8888/")

  smartchat_url = JSON.parse(response.body)["_links"]["smartchat:media"]["href"]
  client.basic_auth("eric", sign_url(private_key, smartchat_url))
  response = client.post(smartchat_url, {
    :media => {
      :friend_ids => friends.map { |f| f["id"] },
      :file_name => "smartchat.png",
      :file => Base64.encode64(File.read("spec/fixtures/file.png"))
    }
  }.to_json)

  raise "Error creating media" unless response.status == 202
ensure
  DatabaseCleaner.clean
end
