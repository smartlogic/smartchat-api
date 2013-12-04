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
          "smartchat:register-user" => {
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
        signed_base64 = Base64.encode64(private_key.sign(digest, path))
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
        signed_base64 = Base64.encode64(private_key.sign(digest, "/another_path"))
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
