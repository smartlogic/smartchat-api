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
  end
end
