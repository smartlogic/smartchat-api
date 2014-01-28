require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Users" do
  include_context :routes

  header "Content-Type", "application/json"

  post "/users" do
    parameter :username, "Username of user", :required => true, :scope => :user
    parameter :email, "Email of user", :required => true, :scope => :user
    parameter :password, "Password of user", :required => true, :scope => :user

    let(:raw_post) { params.to_json }

    let(:username) { "eric" }
    let(:email) { "eric@example.com" }
    let(:password) { "password" }

    example_request "Creating a new user" do
      expect(response_body).to be_json_eql({
        :username => "eric",
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
      let(:username) { nil }
      let(:email) { nil }
      let(:password) { nil }

      example_request "Creating a new user - failure" do
        expect(response_body).to be_json_eql({
          "_embedded" => {
            "errors" => {
              "username" => [
                "can't be blank"
              ],
              "email" => [
                "can't be blank"
              ],
              "password" => [
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
  end

  post "/users/sign_in" do
    header "Authorization", :auth

    let(:auth) do
      user_string = "#{username}:#{password}"
      "Basic #{Base64.encode64(user_string)}"
    end

    let!(:user) do
      UserService.create({
        :username => "eric",
        :email => "eric@example.com",
        :password => "password",
      })
    end

    let(:username) { user.username }
    let(:password) { "password" }

    example_request "Signing in" do
      expect(response_body).to be_json_eql({
        :username => "eric",
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

  get "/users/sms/verify" do
    include_context :auth

    example_request "Viewing verification code to send via SMS" do
      user.reload
      expect(response_body).to be_json_eql({
        "verification_code" => user.sms_verification_code,
        "_links" => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }],
          "self" => {
            "href" => sms_verify_users_url(:host => host)
          }
        }
      }.to_json)
      expect(status).to eq(200)
    end
  end

  post "/users/sms/confirm" do
    include_context :auth

    header "Content-Type", "application/x-www-form-urlencoded"

    parameter :AccountSid, "Account ID of Twilio account - must match", :required => true
    parameter :Body, "Body of SMS message", :required => true
    parameter :From, "Phone number sent from", :required => true

    before do
      user.generate_sms_verification_code

      AppContainer.stub(:twilio_account_sid) { "twilio-account" }
    end

    let(:AccountSid) { "twilio-account" }
    let(:Body) { "Body of text - #{user.sms_verification_code}" }
    let(:From) { "+11231231234" }

    example_request "Twilio verification" do
      explanation "This is twilio sending us a received message"

      expect(response_body).to eq(
        <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Sms>
    Your phone number has been verified.
  </Sms>
</Response>
        XML
      )
      expect(status).to eq(200)

      user.reload

      expect(user.phone_number).to eq("1231231234")
    end

    context "bad Body", :document => false do
      let(:Body) { "Body of text" }

      example_request "Twilio verification" do
        expect(response_body).to eq(
          <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<Response>
</Response>
          XML
        )
        expect(status).to eq(422)
      end
    end

    context "bad AccountSid", :document => false do
      let(:AccountSid) { "bad id" }

      example_request "Twilio verification" do
        expect(status).to eq(403)
      end
    end
  end
end
