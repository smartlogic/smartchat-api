require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Friends" do
  include_context :auth
  include_context :routes

  get "/friends" do
    example_request "Listing friends" do
      expect(response_body).to be_json_eql({
        "_embedded" => {
          "friends" => []
        },
        "_links" => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }],
          "search" => {
            "name" => "Search for friends",
            "href" => search_friends_url(:host => host) + "{?email}",
            "templated" => true
          }
        }
      }.to_json)
      expect(status).to eq(200)
    end
  end

  post "/friends/search" do
    parameter :email, "User's email to search for"

    let(:email) { "other@example.com" }

    let!(:other_user) do
      UserService.create({
        :email => "other@example.com",
        :password => "password",
        :phone => "123-123-1234"
      })
    end

    example_request "Finding a match" do
      expect(response_body).to be_json_eql({
        "_embedded" => {
          "friends" => [
            {
              "email" => "other@example.com",
              "_links" => {
                "smartchat:add-friend" => {
                  "name" => "Add as a friend",
                  "href" => add_friend_url(other_user.id, :host => host)
                }
              }
            }
          ]
        },
        "_links" => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }],
          "search" => {
            "name" => "Search for friends",
            "href" => search_friends_url(:host => host) + "{?email}",
            "templated" => true
          }
        }
      }.to_json)
      expect(status).to eq(200)
    end
  end
end
