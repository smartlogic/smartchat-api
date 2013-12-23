require 'spec_helper'

describe NotificationService do
  let(:created_at) { Time.now }

  let(:device_notification_attrs) { {
    "creator" => {
      "id" => 1,
      "email" => "eric@example.com"
    },
    "devices" => [{
      "device_id" => "device id",
      "device_type" => "android"
    }],
    "s3_file_path" => "path/to/file.png",
    "drawing_s3_file_path" => "path/to/drawing.png",
    "created_at" => created_at,
    "encrypted_aes_key" => "encrypted aes key",
    "encrypted_aes_iv" => "encrypted aes iv",
    "drawing_encrypted_aes_key" => "encrypted aes key",
    "drawing_encrypted_aes_iv" => "encrypted aes iv"
  } }

  class TestAndroidNotifier
    class << self
      attr_reader :message_params

      def notify(args)
        @message_params = args
      end
    end
  end

  it "should send device notifications" do
    container = Struct.new(:android_notifier, :s3_host).
      new(TestAndroidNotifier, "http://s3.amazon.com/")

    NotificationService.send_notification_to_devices(device_notification_attrs, container)

    expect(TestAndroidNotifier.message_params).to eq({
      "device_id" => "device id",
      "message" => {
        "s3_file_url" => "http://s3.amazon.com/path/to/file.png",
        "drawing_s3_file_url" => "http://s3.amazon.com/path/to/drawing.png",
        "created_at" => created_at,
        "creator_id" => 1,
        "creator_email" => "eric@example.com",
        "encrypted_aes_key" => "encrypted aes key",
        "encrypted_aes_iv" => "encrypted aes iv",
        "drawing_encrypted_aes_key" => "encrypted aes key",
        "drawing_encrypted_aes_iv" => "encrypted aes iv"
      }
    })
  end

  it "should send device notifications minus drawing information" do
    device_notification_attrs.delete("drawing_s3_file_path")
    device_notification_attrs.delete("drawing_encrypted_aes_key")
    device_notification_attrs.delete("drawing_encrypted_aes_iv")

    container = Struct.new(:android_notifier, :s3_host).
      new(TestAndroidNotifier, "http://s3.amazon.com/")

    NotificationService.send_notification_to_devices(device_notification_attrs, container)

    expect(TestAndroidNotifier.message_params).to eq({
      "device_id" => "device id",
      "message" => {
        "s3_file_url" => "http://s3.amazon.com/path/to/file.png",
        "created_at" => created_at,
        "creator_id" => 1,
        "creator_email" => "eric@example.com",
        "encrypted_aes_key" => "encrypted aes key",
        "encrypted_aes_iv" => "encrypted aes iv",
      }
    })
  end
end
