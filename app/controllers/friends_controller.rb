class FriendsController < ApplicationController
  def index
    render :json => [], :status => 200, :serializer => FriendsSerializer
  end

  def search
    render({
      :json => User.where(:email => params[:email]),
      :status => 200,
      :serializer => FriendSearchSerializer,
      :each_serializer => FriendSearchUserSerializer
    })
  end
end
