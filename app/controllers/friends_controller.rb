class FriendsController < ApplicationController
  def index
    render({
      :json => FriendService.find_friends(current_user),
      :status => 200,
      :serializer => FriendsSerializer,
      :each_serializer => FriendSerializer
    })
  end

  def search
    render({
      :json => User.with_hashed_phone_numbers(params[:phone_numbers]),
      :status => 200,
      :serializer => FriendSearchSerializer,
      :each_serializer => FriendSearchUserSerializer
    })
  end

  def add
    friend_user = User.find(params[:id])
    FriendService.create(current_user, friend_user)
    render :json => {}, :status => 201, :serializer => AddFriendSerializer
  end
end
