require 'spec_helper'

describe FriendService do
  it "should create a friend relationship" do
    eric = create_user(:username => "eric", :email => "eric@example.com")
    sam = create_user(:username => "sam", :email => "sam@example.com")

    FriendService.create(eric, sam)

    expect(Friend.count).to eq(1)
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
