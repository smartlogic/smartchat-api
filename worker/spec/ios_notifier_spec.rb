require 'spec_helper'

describe IosNotifier do
  class TestApnConnection
    attr_reader :notification

    def push(notification)
      @notification = notification
    end
  end

  let(:apn_connection) { TestApnConnection.new }

  let(:container) do
    double(:container, {
      :apn_connection => apn_connection
    })
  end

  it "should set the alert message for new media" do
    notification_attrs = {
      "device_id" => "device id",
      "message" => {
        "type" => "media",
        "creator_username" => "eric",
      }
    }

    IosNotifier.notify(notification_attrs, container)

    expect(apn_connection.notification.alert).to eq("New smartchat from eric")
    expect(apn_connection.notification.sound).to eq("sosumi.aiff")
  end

  it "should set the alert message for new friend" do
    notification_attrs = {
      "device_id" => "device id",
      "message" => {
        "type" => "friend-added",
        "groupie_username" => "eric",
      }
    }

    IosNotifier.notify(notification_attrs, container)

    expect(apn_connection.notification.alert).to eq("eric added you!")
    expect(apn_connection.notification.sound).to eq("sosumi.aiff")
  end
end
