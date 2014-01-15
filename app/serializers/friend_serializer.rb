class FriendSerializer < ActiveModel::Serializer
  root false

  attributes :id, :username
end
