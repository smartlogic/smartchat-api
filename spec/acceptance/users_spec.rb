require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Users" do
  include_context :routes

  header "Content-Type", "application/json"

  post "/users" do
    parameter :email, "Email of user", :required => true, :scope => :user
    parameter :password, "Password of user", :required => true, :scope => :user
    parameter :phone, "Phone number of user", :required => true, :scope => :user

    let(:raw_post) { params.to_json }

    let(:email) { "eric@example.com" }
    let(:password) { "password" }
    let(:phone) { "123-123-1234" }

    example_request "Creating a new user" do
      expect(response_body).to be_json_eql({
        :email => "eric@example.com",
        :_links => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }]
        }
      }.to_json).excluding("private_key")
      expect(response_body).to have_json_path("private_key")
      expect(status).to eq(201)
    end
  end

  post "/users/sign_in" do
    header "Authorization", :auth

    let(:auth) do
      user_string = "#{email}:#{password}"
      "Basic #{Base64.encode64(user_string)}"
    end

    let!(:user) do
      UserService.create({
        :email => "eric@example.com",
        :password => "password",
        :phone => "123-123-1234"
      })
    end

    let(:email) { user.email }
    let(:password) { "password" }

    example_request "Signing in" do
      expect(response_body).to be_json_eql({
        :email => "eric@example.com",
        :_links => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }]
        }
      }.to_json).excluding("private_key")
      expect(response_body).to have_json_path("private_key")
      expect(status).to eq(200)
    end
  end
end
