module NotificationService
  def notify(friend_id, media, user_klass = User, container = AppContainer)
    user = user_klass.find(friend_id)

    devices = []

    if user.device
      devices << { "device_id" => user.device_id, "device_type" => user.device_type }
    end

    container.queue.send_message({
      "queue" => "media",
      "uuid" => media.fetch("uuid"),
      "user_id" => friend_id,
      "public_key" => user.public_key,
      "created_at" => media.fetch("created_at"),
      "file_path" => media.fetch("file"),
      "drawing_path" => media.fetch("drawing"),
      "expire_in" => media.fetch("expire_in"),
      "pending" => media.fetch("pending"),
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

  def media_viewed(user, smarch_id, container = AppContainer)
    smarch = Smarch.find(smarch_id)
    creator = smarch.creator

    return unless creator.device

    devices = []
    devices << {
      "device_id" => creator.device_id,
      "device_type" => creator.device_type
    }

    container.queue.send_message({
      "queue" => "send-device-notification",
      "user_id" => creator.id,
      "devices" => devices,
      "message" => {
        "type" => "media-viewed",
        "uuid" => smarch.id,
        "user_id" => user.id,
      }
    }.to_json)
  end
  module_function :media_viewed
end
