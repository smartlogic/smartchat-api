require 'spec_helper'
require 'rspec_api_documentation/dsl'

resource "Media" do
  include_context :auth
  include_context :routes

  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let!(:other_user) do
    UserService.create({
      :email => "other@example.com",
      :password => "password",
      :phone => "123-123-1234"
    })
  end

  post "/media" do
    parameter :friend_ids, "Array of friend's ids to send this media to", :required => true, :scope => :media
    parameter :file_name, "File name", :required => true, :scope => :media
    parameter :file, "The photo or video", :required => true, :scope => :media

    let(:friend_ids) { [other_user.id] }
    let(:file_name) { "file.png" }
    let(:file) do
      bits = File.read(Rails.root.join("spec", "fixtures", "file.png"))
      Base64.encode64(bits)
    end

    let(:raw_post) { params.to_json }

    example_request "Uploading a new media file" do
      expect(response_body).to be_json_eql({
        "_links" => {
          "curies" =>  [{
            "name" =>  "smartchat",
            "href" =>  "http://smartchat.smartlogic.io/relations/{rel}",
            "templated" => true
          }],
        }
      }.to_json)
      expect(status).to eq(201)
    end
  end
end
