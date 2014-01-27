module FriendService
  def create(from_user, to_user, container = AppContainer)
    Friend.create({
      :from_id => from_user.id,
      :to_id => to_user.id
    })

    container.notification_service.friend_added(to_user, from_user)
  end
  module_function :create

  def find_friends(for_user)
    Friend.where(:from_id => for_user.id).joins(:to).map(&:to)
  end
  module_function :find_friends

  def friends_with_user?(for_user_id, to_user_id)
    Friend.where(:from_id => for_user_id, :to_id => to_user_id).present?
  end
  module_function :friends_with_user?

  def has_groupies?(user_id)
    groupies(user_id).present?
  end
  module_function :has_groupies?

  def groupies(user_id)
    Friend.joins(:from).
      where(:to_id => user_id).
      where("friends.from_id not in (select friends.to_id from friends where friends.from_id = ?)", user_id).map(&:from)
  end
  module_function :groupies
end
