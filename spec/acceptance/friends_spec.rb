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
          "self" => {
            "name" => "List of your friends",
            "href" => friends_url(:host => host)
          },
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
    header "Content-Type", "application/json"

    parameter :phone_numbers, "User phone numbers to search for"
    parameter :emails, "User emails to search for"

    let(:phone_numbers) { [Digest::MD5.hexdigest(user_1.phone_number)] }
    let(:emails) { [Digest::MD5.hexdigest(user_2.email)] }

    let(:raw_post) { params.to_json }

    let!(:your_friend) do
      friend = UserService.create({
        :email => "friend@example.com",
        :password => "password",
        :phone_number => "123-123-1235"
      })

      FriendService.create(user, friend)

      friend
    end

    let!(:user_1) do
      UserService.create({
        :email => "other@example.com",
        :password => "password",
        :phone_number => "123-123-1235"
      })
    end

    let!(:user_2) do
      UserService.create({
        :email => "user_2@example.com",
        :password => "password",
      })
    end

    example_request "Finding a match" do
      expect(response_body).to be_json_eql({
        "_embedded" => {
          "friends" => [
            {
              "phone_number" => Digest::MD5.hexdigest("1231231235"),
              "_links" => {
                "smartchat:add-friend" => {
                  "name" => "Add as a friend",
                  "href" => add_friend_url(user_1.id, :host => host)
                }
              }
            },
            {
              "email" => Digest::MD5.hexdigest("user_2@example.com"),
              "_links" => {
                "smartchat:add-friend" => {
                  "name" => "Add as a friend",
                  "href" => add_friend_url(user_2.id, :host => host)
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
            "href" => search_friends_url(:host => host) + "{?phone_numbers}",
            "templated" => true
          }
        }
      }.to_json)
      expect(status).to eq(200)
    end
  end

  post "/friends/:id/add" do
    let(:id) { other_user.id }

    let!(:other_user) do
      UserService.create({
        :email => "other@example.com",
        :password => "password",
        :phone_number => "123-123-1234"
      })
    end

    example_request "Adding a user" do
      expect(response_body).to be_json_eql({
        "_links" => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }],
          "smartchat:friends" => {
            "name" => "List of your friends",
            "href" => friends_url(:host => host)
          }
        }
      }.to_json)
      expect(status).to eq(201)

      client.get("/friends", "", headers.merge({
        "Authorization" => sign_header(private_key, user.email, "http://example.org/friends")
      }))

      expect(response_body).to be_json_eql({
        "_embedded" => {
          "friends" => [
            {
              :email => "other@example.com"
            }
          ]
        },
        "_links" => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }],
          "self" => {
            "name" => "List of your friends",
            "href" => friends_url(:host => host)
          },
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
