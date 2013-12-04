class RootSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  def _links
    if current_user
      super
    else
      super.merge({
        "smartchat:register-user" => {
          :href => users_url
        }
      })
    end
  end
end
