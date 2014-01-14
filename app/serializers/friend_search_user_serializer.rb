class FriendSearchUserSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :email, :phone_number

  def email
    Digest::MD5.hexdigest(user.email)
  end

  def phone_number
    Digest::MD5.hexdigest(user.phone)
  end

  def include_phone_number?
    user[:found_by_phone]
  end

  def include_email?
    user[:found_by_email]
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
