require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Device" do
  include_context :auth
  include_context :routes

  header "Accept", "application/json"
  header "Content-Type", "application/json"

  post "/device" do
    parameter :device_id, "Device ID", :required => true, :scope => :device
    parameter :device_type, "Android or iOS", :required => true, :scope => :device

    let(:device_id) { "123" }
    let(:device_type) { "android" }

    let(:raw_post) { params.to_json }

    example_request "Register a new device" do
      explanation "This will overwrite the previous device"

      expect(response_body).to be_json_eql({
        "_links" => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "https://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }]
        }
      }.to_json)
      expect(status).to eq(201)
    end
  end
end
