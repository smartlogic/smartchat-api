class FriendSearchUserSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :email, :phone_number

  def phone_number
    Digest::MD5.hexdigest(user.phone)
  end

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
