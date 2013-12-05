class RootSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  def _links
    if current_user
      super.merge({
        "smartchat:friends" => {
          :href => friends_url
        },
        "smartchat:media" => {
          "name" => "Create a smartchat",
          "href" => media_index_url
        },
        "smartchat:devices" => {
          "name" => "Register a new device",
          "href" => device_url
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
