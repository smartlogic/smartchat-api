class RootSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  def _links
    if current_user
      super.merge({
        "smartchat:friends" => {
          :href => friends_url
        }
      })
    else
      super.merge({
        "smartchat:register-user" => {
          :href => users_url
        }
      })
    end
  end
end
