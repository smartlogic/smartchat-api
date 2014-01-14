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

    context "bad data", :document => false do
      let(:email) { nil }
      let(:password) { nil }
      let(:phone) { nil }

      example_request "Creating a new user - failure" do
        expect(response_body).to be_json_eql({
          "_embedded" => {
            "errors" => {
              "email" => [
                "can't be blank"
              ],
              "password" => [
                "can't be blank"
              ],
              "phone" => [
                "can't be blank"
              ]
            }
          },
          "_links" => {
            "curies" =>  [{
              "name" =>  "smartchat",
              "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
              "templated" => true
            }]
          }
        }.to_json)
        expect(status).to eq(422)
      end
    end

    context "bad data", :document => false do
      let(:email) { "eric" }

      example_request "Creating a new user - invalid data" do
        expect(response_body).to be_json_eql({
          "_embedded" => {
            "errors" => {
              "email" => [
                "not an email address"
              ]
            }
          },
          "_links" => {
            "curies" =>  [{
              "name" =>  "smartchat",
              "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
              "templated" => true
            }]
          }
        }.to_json)
        expect(status).to eq(422)
      end
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

  post "/users/invite" do
    include_context :auth

    parameter :email, "User email to invite", :required => true
    parameter :message, "Custom message from user to include", :required => true

    let(:email) { "eric@example.com" }
    let(:message) { "Check this out!" }

    let(:raw_post) { params.to_json }

    before do
      AppContainer.stub(:queue) do
        double(:queue, :send_message => true)
      end
    end

    example_request "Sending an invite" do
      expect(response_body).to be_empty
      expect(status).to eq(204)
    end
  end
end
