require 'spec_helper'

describe FriendService do
  it "should notify the other user if they have a device attached" do
    eric = create_user(:username => "eric", :email => "eric@example.com")
    sam = create_user(:username => "sam", :email => "sam@example.com")

    sam.create_device(:device_type => "android", :device_id => "abc")

    notification = double(:notification)
    container = double(:container, :notification_service => notification)

    expect(notification).to receive(:friend_added).with(sam, eric)

    FriendService.create(eric, sam, container)
  end
  
  it "should find all friends associated with a user" do
    eric = create_user(:username => "eric", :email => "eric@example.com")
    sam = create_user(:username => "sam", :email => "sam@example.com")

    FriendService.create(eric, sam)

    friends = FriendService.find_friends(eric)

    expect(friends).to eq([sam])
  end

  it "should know if a user is friends with another" do
    eric = create_user(:username => "eric", :email => "eric@example.com")
    sam = create_user(:username => "sam", :email => "sam@example.com")

    expect(FriendService.friends_with_user?(eric.id, sam.id)).to be_false

    FriendService.create(eric, sam)

    expect(FriendService.friends_with_user?(eric.id, sam.id)).to be_true
  end

  it "should find groupies" do
    eric = create_user(:username => "eric", :email => "eric@example.com")
    sam = create_user(:username => "sam", :email => "sam@example.com")

    expect(FriendService.has_groupies?(eric.id)).to be_false

    FriendService.create(sam, eric)

    expect(FriendService.has_groupies?(eric.id)).to be_true
    expect(FriendService.groupies(eric.id)).to eq([sam])

    FriendService.create(eric, sam)

    expect(FriendService.has_groupies?(eric.id)).to be_false
  end
end
