require 'spec_helper'

describe MediaWorker do
  let(:created_at) { Time.now }

  let(:media_attributes) { {
    "id" => 3,
    "user_id" => 2,
    "public_key" => "public_key",
    "created_at" => created_at,
    "file_path" => "file_path",
    "drawing_path" => "drawing_path",
    "devices" => [{
      "device_id" => "a device id",
      "device_type" => "android"
    }],
    "creator" => {
      "id" => 1,
      "email" => "eric@example.com"
    }
  } }

  let(:encryptor) { TestEncryptor.new }

  it "publish the file and drawing to the media store" do
    notification = TestNotificationService.new
    media_store = TestMediaStore.new("file_path" => "file", "drawing_path" => "drawing")

    container = double(:container, {
      :media_store => media_store,
      :smartchat_encryptor => TestEncryptorFactory.new(encryptor),
      :notification_service => notification
    })

    MediaWorker.new.perform(media_attributes, container)

    expect(notification.lookup("android", "a device id")).to eq({
      "file_url" => "file_url",
      "drawing_file_url" => "drawing_url",
      "created_at" => created_at,
      "creator_id" => 1,
      "creator_email" => "eric@example.com",
    })
    expect(media_store["file_path"]).to eq("elif")
    expect(media_store["drawing_path"]).to eq("gniward")
  end

  it "should handle no drawing" do
    notification = TestNotificationService.new
    media_store = TestMediaStore.new("file_path" => "file")

    container = double(:container, {
      :media_store => media_store,
      :smartchat_encryptor => TestEncryptorFactory.new(encryptor),
      :notification_service => notification
    })

    media_attributes.delete("drawing_path")
    MediaWorker.new.perform(media_attributes, container)

    expect(notification.lookup("android", "a device id")).to eq({
      "file_url" => "file_url",
      "created_at" => created_at,
      "creator_id" => 1,
      "creator_email" => "eric@example.com",
    })
  end
end
