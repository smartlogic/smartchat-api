class FriendSerializer < ActiveModel::Serializer
  root false

  attributes :id, :email
end
