class AddFriendSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  def _links
    super.merge({
      "smartchat:friends" => {
        "name" => "List of your friends",
        "href" => friends_url
      }
    })
  end
end
