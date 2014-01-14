class UserErrorSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :_embedded

  def _embedded
    {
      "errors" => @object
    }
  end
end
