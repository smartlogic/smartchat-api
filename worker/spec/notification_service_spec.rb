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

  it "should send device notifications" do
    android_notifier = double(:AndroidNotifier)
    container = double(:container, {
      :android_notifier => android_notifier,
      :s3_host => "http://s3.amazon.com/"
    })

    expect(android_notifier).to receive(:notify).with({
      "device_id" => "device id",
      "message" => {
        "s3_file_url" => "http://s3.amazon.com/path/to/file.png",
        "created_at" => created_at,
        "creator" => {
          "id" => 1,
          "email" => "eric@example.com"
        },
        "encrypted_aes_key" => "encrypted aes key",
        "encrypted_aes_iv" => "encrypted aes iv"
      }
    })

    NotificationService.send_notification_to_devices(
      device_notification_attrs,
      container
    )
  end
end
