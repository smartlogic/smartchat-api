require 'spec_helper'

describe SendDeviceNotificationWorker do
  it "should send a notification to the device" do
    body = {
      "user_id" => 1,
      "devices" => [{
        "device_type" => "android",
        "device_id" => "a device id"
      }],
      "message" => {
        "data" => "is sent"
      }
    }

    notification = TestNotificationService.new
    container = double(:container, :notification_service => notification)

    SendDeviceNotificationWorker.new.perform(body, container)

    expect(notification.lookup("android", "a device id")).to eq({
      "data" => "is sent"
    })
  end
end
