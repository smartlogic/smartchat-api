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
      :phone_number => "123-123-1234"
    })
  end

  before do
    other_user.create_device(:device_id => "123", :device_type => "android")
    AppContainer.stub(:queue) do
      double(:queue, :send_message => true)
    end
  end

  get "/media" do
    before do
      store = AppContainer.media_store
      file_path = store.store("spec/fixtures/file.txt")
      drawing_path = store.store("spec/fixtures/file.txt")

      encryptor = TestEncryptor.new
      store.publish(file_path, user.id, "folder", "file.png", encryptor, {
        "creator_id" => 1,
        "creator_email" => "eric@example.com",
        "created_at" => Time.now
      })
      store.publish(drawing_path, user.id, "folder", "drawing.png", encryptor)
    end

    example_request "Get a list of media to view" do
      expect(response_body).to be_json_eql({
        "_embedded" => {
          "media" => [
            {
              "_embedded" => {
                "creator" => {
                  "id" => 1,
                  "email" => "eric@example.com",
                }
              },
              "_links" => {
                "curies" => [
                  {
                    "href" => "http://smartchat.smartlogic.io/relations/{rel}",
                    "name" => "smartchat",
                    "templated" => true
                  }
                ],
                "smartchat:files" => [
                  {
                    "href" => "http://example.org/files/users/#{user.id}/folder/file.png",
                    "name" => "file"
                  },
                  {
                    "href" => "http://example.org/files/users/#{user.id}/folder/drawing.png",
                    "name" => "drawing"
                  }
                ]
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
        }
      }.to_json)
      expect(status).to eq(200)
    end
  end

  post "/media" do
    parameter :friend_ids, "Array of friend's ids to send this media to", :required => true, :scope => :media
    parameter :file_name, "File name", :required => true, :scope => :media
    parameter :file, "The photo or video", :required => true, :scope => :media
    parameter :drawing, "PNG of user's drawing", :scope => :media

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
      expect(status).to eq(202)
    end

    context "Sending a drawing", :document => false do
      let(:drawing) do
        bits = File.read(Rails.root.join("spec", "fixtures", "file.png"))
        Base64.encode64(bits)
      end

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
        expect(status).to eq(202)
      end
    end
  end
end
