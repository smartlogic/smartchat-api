require 'spec_helper'

describe NotificationService do
  let(:created_at) { Time.now }


  let(:notification) { "notification" }

  class TestNotifier
    class << self
      attr_reader :message_params

      def notify(args)
        @message_params = args
      end

      def reset!
        @message_params = nil
      end
    end
  end

  before do
    TestNotifier.reset!
  end

  it "should send device notifications" do
    devices = [{
      "device_id" => "device id",
      "device_type" => "android"
    }]

    container = Struct.new(:android_notifier).new(TestNotifier)

    NotificationService.send_notification_to_devices(devices, notification, container)

    expect(TestNotifier.message_params).to eq({
      "device_id" => "device id",
      "message" => notification
    })
  end

  it "should send ios device notifications" do
    devices = [{
      "device_id" => "device id",
      "device_type" => "iOS"
    }]

    container = Struct.new(:ios_notifier).new(TestNotifier)

    NotificationService.send_notification_to_devices(devices, notification, container)

    expect(TestNotifier.message_params).to eq({
      "device_id" => "device id",
      "message" => notification
    })
  end
end
