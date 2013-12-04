class FriendSearchUserSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :email

  def _links
    {
      "smartchat:add-friend" => {
        "name" => "Add as a friend",
        "href" => add_friend_url(user.id)
      }
    }
  end

  private

  def user
    @object
  end
end
