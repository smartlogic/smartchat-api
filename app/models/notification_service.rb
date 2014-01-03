module NotificationService
  def notify(friend_id, media, user_klass = User, container = AppContainer)
    user = user_klass.find(friend_id)

    devices = []

    if user.device
      devices << { "device_id" => user.device_id, "device_type" => user.device_type }
    end

    container.sqs_queue.send_message({
      "queue" => "media",
      "id" => media.id,
      "user_id" => friend_id,
      "public_key" => user.public_key,
      "created_at" => media.created_at,
      "file_path" => media.file,
      "drawing_path" => media.drawing,
      "devices" => devices,
      "creator" => {
        "id" => media.poster_id,
        "email" => media.poster_email
      }
    }.to_json)
  end
  module_function :notify
end
