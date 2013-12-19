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
    "created_at" => created_at,
    "encrypted_aes_key" => "encrypted aes key",
    "encrypted_aes_iv" => "encrypted aes iv"
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
    container = double(:container, {
      :android_notifier => TestAndroidNotifier,
      :s3_host => "http://s3.amazon.com/"
    })

    NotificationService.send_notification_to_devices(device_notification_attrs, container)

    expect(TestAndroidNotifier.message_params).to eq({
      "device_id" => "device id",
      "message" => {
        "s3_file_url" => "http://s3.amazon.com/path/to/file.png",
        "created_at" => created_at,
        "creator_id" => 1,
        "creator_email" => "eric@example.com",
        "encrypted_aes_key" => "encrypted aes key",
        "encrypted_aes_iv" => "encrypted aes iv"
      }
    })
  end
end
