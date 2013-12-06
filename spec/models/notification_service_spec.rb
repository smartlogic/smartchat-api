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
        "id" => "a device id",
        "type" => "android"
      }],
      "creator" => {
        "id" => 1,
        "email" => "eric@example.com"
      }
    }.to_json)

    NotificationService.notify(2, media, user_klass, container)
  end

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
    "created_at" => created_at
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
        }
      }
    })

    NotificationService.send_notification_to_devices(
      device_notification_attrs,
      container
    )
  end
end
