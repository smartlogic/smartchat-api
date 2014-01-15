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
      "devices" => devices,
      "creator" => {
        "id" => media.fetch("poster_id"),
        "username" => media.fetch("poster_username")
      }
    }.to_json)
  end
  module_function :notify
end
