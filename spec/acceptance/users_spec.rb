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
      }.to_json)
      expect(status).to eq(201)
    end
  end
end
