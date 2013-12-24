require 'spec_helper'

describe NotificationService do
  let(:created_at) { Time.now }

  let(:devices) { [{
    "device_id" => "device id",
    "device_type" => "android"
  }] }

  let(:notification) { "notification" }

  class TestAndroidNotifier
    class << self
      attr_reader :message_params

      def notify(args)
        @message_params = args
      end
    end
  end

  it "should send device notifications" do
    container = Struct.new(:android_notifier).new(TestAndroidNotifier)

    NotificationService.send_notification_to_devices(devices, notification, container)

    expect(TestAndroidNotifier.message_params).to eq({
      "device_id" => "device id",
      "message" => notification
    })
  end
end
