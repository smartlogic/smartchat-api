require 'spec_helper'

describe NotificationService do
  it "should notify users" do
    created_at = Time.now

    media = double(:media, {
      :id => 3,
      :user_id => 1,
      :user_email => "eric@example.com",
      :created_at => created_at,
      :file => double(:uploader, :path => "/path/to/file.png")
    })
    friend = double(:friend, {
      :public_key => "public_key",
      :device => true,
      :device_type => "android",
      :device_id => "a device id"
    })

    user_klass = double(:User)
    expect(user_klass).to receive(:find).with(2).and_return(friend)

    queue = double(:queue)
    container = double(:container, :sqs_queue => queue)

    expect(queue).to receive(:send_message).with({
      "id" => 3,
      "user_id" => 2,
      "public_key" => "public_key",
      "created_at" => created_at,
      "file_path" => "/path/to/file.png",
      "devices" => [{
        "device_id" => "a device id",
        "device_type" => "android"
      }],
      "creator" => {
        "id" => 1,
        "email" => "eric@example.com"
      }
    }.to_json)

    NotificationService.notify(2, media, user_klass, container)
  end
end
