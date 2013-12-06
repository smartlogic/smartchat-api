require 'openssl'

require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Root" do
  include_context :routes

  get "/" do
    example_request "Unauthorized" do
      expect(response_body).to be_json_eql({
        :_links => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }],
          "smartchat:user" => {
            :href => users_url(:host => host)
          }
        }
      }.to_json)

      expect(status).to eq(200)
    end

    context "signed body" do
      header "Authorization", :auth_header

      let!(:user) do
        UserService.create({
          :email => "eric@example.com",
          :password => "password",
          :phone => "123-123-1234"
        })
      end

      let(:private_key) do
        OpenSSL::PKey::RSA.new user.private_key, User.hash_password_for_private_key("password")
      end

      let(:auth_header) do
        digest = OpenSSL::Digest::SHA256.new
        signed_base64 = Base64.encode64(private_key.sign(digest, "http://example.org#{path}"))
        user_string = "eric@example.com:#{signed_base64}"
        "Basic #{Base64.encode64(user_string)}"
      end

      example_request "Authorized" do
        expect(response_body).to be_json_eql({
          :_links => {
            "curies" =>  [{
              "name" =>  "smartchat",
              "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
              "templated" => true
            }],
            "smartchat:friends" => {
              "href" => friends_url(:host => host)
            },
            "smartchat:media" => {
              "name" => "Create a smartchat",
              "href" => media_index_url(:host => host)
            },
            "smartchat:devices" => {
              "name" => "Register a new device",
              "href" => device_url(:host => host)
            }
          }
        }.to_json)

        expect(status).to eq(200)
      end
    end

    context "signed invalid body", :document => false do
      header "Authorization", :auth_header

      let!(:user) do
        UserService.create({
          :email => "eric@example.com",
          :password => "password",
          :phone => "123-123-1234"
        })
      end

      let(:private_key) do
        OpenSSL::PKey::RSA.new user.private_key, User.hash_password_for_private_key("password")
      end

      let(:auth_header) do
        digest = OpenSSL::Digest::SHA256.new
        signed_base64 = Base64.encode64(private_key.sign(digest, "http://example.com/another_path"))
        user_string = "eric@example.com:#{signed_base64}"
        "Basic #{Base64.encode64(user_string)}"
      end

      example_request "Unauthorized" do
        expect(status).to eq(401)
      end

      example "User doesn't exist" do
        user.update!(:email => "eric@example.org")

        do_request

        expect(status).to eq(401)
      end
    end
  end
end
