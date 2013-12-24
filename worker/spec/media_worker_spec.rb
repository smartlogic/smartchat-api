require 'spec_helper'

describe MediaWorker do
  let(:created_at) { Time.now }

  let(:media_attributes) { {
    "id" => 3,
    "user_id" => 2,
    "public_key" => "public_key",
    "created_at" => created_at,
    "file_path" => "uploads/media/3/file.png",
    "drawing_path" => "uploads/media/3/drawing.png",
    "devices" => [{
      "id" => "a device id",
      "type" => "android"
    }],
    "creator" => {
      "id" => 1,
      "email" => "eric@example.com"
    }
  } }

  class TestEncryptor
    attr_reader :data

    def initialize
      @data = []
    end

    def encrypt(data)
      @data << data

      ["encrypted aes key", "encrypted aes iv", "encrypted data"]
    end
  end

  class TestNotificationService
    attr_accessor :notifications

    def initialize
      @notifications = []
    end

    def send_notification_to_devices(notification)
      @notifications << notification
    end
  end

  TestEncryptorFactory = Struct.new(:instance) do
    def new(public_key)
      instance
    end
  end

  let(:bucket) { double(:bucket) }
  let(:s3_object) { double(:S3Object) }

  let(:private_bucket) { double(:private_bucket) }
  let(:s3_private_object) { double(:S3Object_private) }

  let(:encryptor) { TestEncryptor.new }

  it "encrypt and upload the media to the user's s3 folder" do
    drawing_s3_object = double(:S3Object)
    drawing_s3_private_object = double(:S3Object_private)

    expect(bucket).to receive(:objects).and_return({
      "users/2/media/3/file.png" => s3_object,
      "users/2/media/3/drawing.png" => drawing_s3_object
    }).exactly(2).times
    expect(s3_object).to receive(:write).with("encrypted data")
    expect(s3_object).to receive(:acl=).with(:public_read)

    expect(drawing_s3_object).to receive(:write).with("encrypted data")
    expect(drawing_s3_object).to receive(:acl=).with(:public_read)

    expect(private_bucket).to receive(:objects).and_return({
      "uploads/media/3/file.png" => s3_private_object,
      "uploads/media/3/drawing.png" => drawing_s3_private_object
    }).exactly(2).times
    expect(s3_private_object).to receive(:read).and_return("file data")
    expect(drawing_s3_private_object).to receive(:read).and_return("drawing data")

    notification = TestNotificationService.new


    container = double(:container, {
      :s3_bucket => bucket,
      :s3_private_bucket => private_bucket,
      :smartchat_encryptor => TestEncryptorFactory.new(encryptor),
      :notification_service => notification
    })

    MediaWorker.new.perform(media_attributes, container)

    expect(encryptor.data.first).to eq("file data")
    expect(encryptor.data.last).to eq("drawing data")
    expect(notification.notifications.first).to eq({
      "s3_file_path" => "users/2/media/3/file.png",
      "drawing_s3_file_path" => "users/2/media/3/drawing.png",
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
  end

  it "should handle no drawing" do
    expect(bucket).to receive(:objects).and_return({
      "users/2/media/3/file.png" => s3_object,
    })
    expect(s3_object).to receive(:write).with("encrypted data")
    expect(s3_object).to receive(:acl=).with(:public_read)

    expect(private_bucket).to receive(:objects).and_return({
      "uploads/media/3/file.png" => s3_private_object,
    })
    expect(s3_private_object).to receive(:read).and_return("file data")

    notification = TestNotificationService.new

    container = double(:container, {
      :s3_bucket => bucket,
      :s3_private_bucket => private_bucket,
      :smartchat_encryptor => TestEncryptorFactory.new(encryptor),
      :notification_service => notification
    })

    media_attributes.delete("drawing_path")
    MediaWorker.new.perform(media_attributes, container)

    expect(notification.notifications.first).to eq({
      "s3_file_path" => "users/2/media/3/file.png",
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
