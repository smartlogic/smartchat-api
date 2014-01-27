require 'spec_helper'

describe FriendService do
  it "should create a friend relationship" do
    friend_klass = double(:Friend)
    user = double(:user, :id => 1)
    friend_user = double(:user, :id => 2)

    expect(friend_klass).to receive(:create).
      with(:from_id => user.id, :to_id => friend_user.id)

    FriendService.create(user, friend_user, friend_klass)
  end
  
  it "should find all friends associated with a user" do
    friend_klass = double(:Friend)
    ar_double = double(:ar)

    user = double(:user, :id => 1)
    friend = double(:friend)

    expect(friend_klass).to receive(:where).with({
      :from_id => user.id
    }).and_return(ar_double)
    expect(ar_double).to receive(:joins).with(:to).
      and_return([double(:to => friend)])

    friends = FriendService.find_friends(user, friend_klass)

    expect(friends).to eq([friend])
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
