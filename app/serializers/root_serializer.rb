class RootSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  def _links
    base_links = super.merge({
      "self" => {
        "href" => root_url
      }
    })

    if current_user
      base_links.merge({
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
      base_links.merge({
        "smartchat:user-sign-in" => {
          "name" => "Sign in",
          "href" => sign_in_users_url
        },
        "smartchat:users" => {
          "name" => "Register a user",
          "href" => users_url
        }
      })
    end
  end
end
