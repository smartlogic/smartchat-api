class UserSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :email
end
