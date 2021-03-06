require 'spec_helper'

describe NotificationService do
  class TestQueue
    attr_reader :messages

    def initialize
      @messages = []
    end

    def send_message(message)
      @messages << message
    end
  end

  it "should notify users" do
    created_at = Time.now

    media = {
      "uuid" => "uuid",
      "poster_id" => 1,
      "poster_username"=> "eric",
      "created_at" => created_at,
      "file" => "path/to/file.png",
      "drawing" => "path/to/drawing.png",
      "expire_in" => 15,
      "pending" => false
    }
    friend = double(:friend, {
      :public_key => "public_key",
      :device => true,
      :device_type => "android",
      :device_id => "a device id"
    })

    user_klass = double(:User)
    expect(user_klass).to receive(:find).with(2).and_return(friend)

    queue = double(:queue)
    container = double(:container, :queue => queue)

    expect(queue).to receive(:send_message).with({
      "queue" => "media",
      "uuid" => "uuid",
      "user_id" => 2,
      "public_key" => "public_key",
      "created_at" => created_at,
      "file_path" => "path/to/file.png",
      "drawing_path" => "path/to/drawing.png",
      "expire_in" => 15,
      "pending" => false,
      "devices" => [{
        "device_id" => "a device id",
        "device_type" => "android"
      }],
      "creator" => {
        "id" => 1,
        "username" => "eric"
      }
    }.to_json)

    NotificationService.notify(2, media, user_klass, container)
  end

  it "should notifiy users of someone adding them as a friend" do
    eric = create_user(:username => "eric", :email => "eric@example.com")
    sam = create_user(:username => "sam", :email => "sam@example.com")

    sam.create_device(:device_id => "a device id", :device_type => "android")

    queue = double(:queue)
    container = double(:container, :queue => queue)

    expect(queue).to receive(:send_message).with({
      "queue" => "send-device-notification",
      "user_id" => sam.id,
      "devices" => [{
        "device_id" => "a device id",
        "device_type" => "android"
      }],
      "message" => {
        "type" => "friend-added",
        "groupie_id" => eric.id,
        "groupie_username" => "eric"
      }
    }.to_json)

    NotificationService.friend_added(sam, eric, container)
  end

  it "should notifiy users when a smarch is read" do
    eric = create_user(:username => "eric", :email => "eric@example.com")
    sam = create_user(:username => "sam", :email => "sam@example.com")

    sam.create_device(:device_id => "a device id", :device_type => "android")

    smarch = Smarch.create(:creator_id => sam.id, :friend_ids => [eric.id])

    queue = TestQueue.new
    container = double(:container, :queue => queue)

    NotificationService.media_viewed(eric, smarch.id, container)

    expect(queue.messages.first).to eq({
      "queue" => "send-device-notification",
      "user_id" => sam.id,
      "devices" => [{
        "device_id" => "a device id",
        "device_type" => "android"
      }],
      "message" => {
        "type" => "media-viewed",
        "uuid" => smarch.id,
        "user_id" => eric.id,
      }
    }.to_json)
  end
end
