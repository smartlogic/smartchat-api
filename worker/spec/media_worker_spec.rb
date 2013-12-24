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
      "id" => "a device id",
      "type" => "android"
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

    expect(notification.notifications.first).to eq({
      "s3_file_path" => "file_path",
      "drawing_s3_file_path" => "drawing_path",
      "created_at" => created_at,
      "devices" => [{
        "id" => "a device id",
        "type" => "android"
      }],
      "creator" => {
        "id" => 1,
        "email" => "eric@example.com"
      },
      "encrypted_aes_key" => Base64.strict_encode64("encrypted aes key"),
      "encrypted_aes_iv" => Base64.strict_encode64("encrypted aes iv"),
      "drawing_encrypted_aes_key" => Base64.strict_encode64("encrypted aes key"),
      "drawing_encrypted_aes_iv" => Base64.strict_encode64("encrypted aes iv")
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

    expect(notification.notifications.first).to eq({
      "s3_file_path" => "file_path",
      "created_at" => created_at,
      "devices" => [{
        "id" => "a device id",
        "type" => "android"
      }],
      "creator" => {
        "id" => 1,
        "email" => "eric@example.com"
      },
      "encrypted_aes_key" => Base64.strict_encode64("encrypted aes key"),
      "encrypted_aes_iv" => Base64.strict_encode64("encrypted aes iv"),
    })
  end
end
