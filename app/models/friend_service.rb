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
end
