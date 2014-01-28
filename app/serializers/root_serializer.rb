class RootSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  def _links
    base_links = super.merge({
      "self" => {
        "href" => root_url
      }
    })

    if current_user
      base_links.merge!(authenticated_links)
    else
      base_links.merge!(unauthenticated_links)
    end

    base_links
  end

  private

  def authenticated_links
    base_links = {
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
      },
      "smartchat:invitations" => {
        "name" => "Invite a user to SmartChat",
        "href" => invite_users_url
      }
    }

    unless current_user.phone_number_verified?
      base_links.merge!({
        "smartchat:sms-verify" => {
          "name" => "Verify your phone number via SMS",
          "href" => sms_verify_users_url
        }
      })
    end

    base_links
  end

  def unauthenticated_links
    {
      "smartchat:user-sign-in" => {
        "name" => "Sign in",
        "href" => sign_in_users_url
      },
      "smartchat:users" => {
        "name" => "Register a user",
        "href" => users_url
      }
    }
  end
end
