module MediaService
  def create(user, params, media_klass = Media, notification_service_klass = NotificationService)
    friend_ids = params.delete(:friend_ids)
    media = media_klass.create(params.merge(:user_id => user.id))

    friend_ids.each do |friend_id|
      notification_service_klass.notify(friend_id, media)
    end
  end
  module_function :create
end
