class RootSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  def _links
    super.merge({
      "smartchat:register-user" => {
        :href => users_url
      }
    })
  end
end
