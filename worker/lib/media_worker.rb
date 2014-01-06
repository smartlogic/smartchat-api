require 'openssl'

class MediaWorker
  def perform(media_attributes, container = AppContainer)
    id = media_attributes.fetch("id")
    user_id = media_attributes.fetch("user_id")
    created_at = media_attributes.fetch("created_at")
    creator = media_attributes.fetch("creator")
    public_key = media_attributes.fetch("public_key")
    devices = media_attributes.fetch("devices")
    file_path = media_attributes.fetch("file_path")

    encryptor = container.smartchat_encryptor.new(public_key)
    media_store = container.media_store

    file_url, encrypted_aes_key, encrypted_aes_iv =
      publish(file_path, user_id, id, encryptor, media_store)

    notification = {
      "creator_id" => creator.fetch("id"),
      "creator_email" => creator.fetch("email"),
      "created_at" => created_at,
      "file_url" => file_url,
      "encrypted_aes_key" => encrypted_aes_key,
      "encrypted_aes_iv" => encrypted_aes_iv
    }

    if media_attributes["drawing_path"]
      drawing_file_path = media_attributes["drawing_path"]

      drawing_file_url, drawing_encrypted_aes_key, drawing_encrypted_aes_iv =
        publish(drawing_file_path, user_id, id, encryptor, media_store)

      notification.merge!({
        "drawing_file_url" => drawing_file_url,
        "drawing_encrypted_aes_key" => drawing_encrypted_aes_key,
        "drawing_encrypted_aes_iv" => drawing_encrypted_aes_iv
      })
    end

    container.notification_service.send_notification_to_devices(devices, notification)
  end

  private

  def publish(path, user_id, id, encryptor, media_store)
    published_url, encrypted_aes_key, encrypted_aes_iv = media_store.publish(path, user_id, id, encryptor)
    [published_url, encrypted_aes_key, encrypted_aes_iv]
  end
end
