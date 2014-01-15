require 'openssl'

class MediaWorker
  def perform(media_attributes, container = AppContainer)
    user_id = media_attributes.fetch("user_id")
    created_at = media_attributes.fetch("created_at")
    creator = media_attributes.fetch("creator")
    public_key = media_attributes.fetch("public_key")
    devices = media_attributes.fetch("devices")
    folder = SecureRandom.hex
    file_path = media_attributes.fetch("file_path")
    extension = File.extname(file_path)

    encryptor = container.smartchat_encryptor.new(public_key)
    media_store = container.media_store

    notification = {
      "creator_id" => creator.fetch("id"),
      "creator_username" => creator.fetch("username"),
      "created_at" => created_at,
    }

    file_url = media_store.publish(file_path, user_id, folder, "file#{extension}", encryptor, notification)

    notification.merge!({
      "file_url" => file_url
    })

    if media_attributes["drawing_path"]
      drawing_file_path = media_attributes["drawing_path"]
      extension = File.extname(drawing_file_path)

      drawing_file_url = media_store.publish(drawing_file_path, user_id, folder, "drawing#{extension}", encryptor)

      notification.merge!({
        "drawing_file_url" => drawing_file_url,
      })
    end

    container.notification_service.send_notification_to_devices(devices, notification)
  end
end
