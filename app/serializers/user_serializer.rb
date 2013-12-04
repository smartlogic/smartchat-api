class UserSerializer < ActiveModel::Serializer
  include ApplicationSerializer

  attributes :email, :private_key
end
