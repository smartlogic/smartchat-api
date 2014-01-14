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
    if params[:phone_numbers].present?
      found_by_phone = User.with_hashed_phone_numbers(params[:phone_numbers]).excluding_friends(current_user)
    else
      found_by_phone = []
    end

    if params[:emails].present?
      found_by_email = User.with_hashed_emails(params[:emails]).excluding_friends(current_user)
    else
      found_by_email = []
    end

    users_found = (found_by_phone + found_by_email).uniq

    render({
      :json => users_found,
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
