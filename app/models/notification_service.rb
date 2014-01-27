module NotificationService
  def notify(friend_id, media, user_klass = User, container = AppContainer)
    user = user_klass.find(friend_id)

    devices = []

    if user.device
      devices << { "device_id" => user.device_id, "device_type" => user.device_type }
    end

    container.queue.send_message({
      "queue" => "media",
      "user_id" => friend_id,
      "public_key" => user.public_key,
      "created_at" => media.fetch("created_at"),
      "file_path" => media.fetch("file"),
      "drawing_path" => media.fetch("drawing"),
      "expire_in" => media.fetch("expire_in"),
      "devices" => devices,
      "creator" => {
        "id" => media.fetch("poster_id"),
        "username" => media.fetch("poster_username")
      }
    }.to_json)
  end
  module_function :notify

  def friend_added(to_user, from_user, container = AppContainer)
    return unless to_user.device

    devices = []
    devices << { "device_id" => to_user.device_id, "device_type" => to_user.device_type }

    container.queue.send_message({
      "queue" => "send-device-notification",
      "user_id" => to_user.id,
      "devices" => devices,
      "message" => {
        "type" => "friend-added",
        "groupie_id" => from_user.id,
        "groupie_username" => from_user.username
      }
    }.to_json)
  end
  module_function :friend_added
end
