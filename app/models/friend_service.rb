module FriendService
  def create(from_user, to_user, friend_klass = Friend)
    friend_klass.create({
      :from_id => from_user.id,
      :to_id => to_user.id
    })
  end
  module_function :create

  def find_friends(for_user, friend_klass = Friend)
    friend_klass.where(:from_id => for_user.id).joins(:to).map(&:to)
  end
  module_function :find_friends

  def friends_with_user?(for_user_id, to_user_id)
    Friend.where(:from_id => for_user_id, :to_id => to_user_id).present?
  end
  module_function :friends_with_user?
end
