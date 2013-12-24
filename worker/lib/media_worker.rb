require 'openssl'
require 'base64'

class MediaWorker
  def perform(media_attributes, container = AppContainer)
    notification = {
      "creator_id" => media_attributes["creator"]["id"],
      "creator_email" => media_attributes["creator"]["email"],
      "created_at" => media_attributes["created_at"],
    }

    id = media_attributes["id"]
    user_id = media_attributes["user_id"]
    encryptor = container.smartchat_encryptor.new(media_attributes["public_key"])
    media_store = container.media_store

    file_path = media_attributes["file_path"]
    file_url, encrypted_aes_key, encrypted_aes_iv =
      publish(file_path, user_id, id, encryptor, media_store)

    notification.merge!({
      "file_url" => file_url,
      "encrypted_aes_key" => encrypted_aes_key,
      "encrypted_aes_iv" => encrypted_aes_iv
    })

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

    devices = media_attributes["devices"]
    container.notification_service.send_notification_to_devices(devices, notification)
  end

  private

  def publish(path, user_id, id, encryptor, media_store)
    public_path, encrypted_aes_key, encrypted_aes_iv = media_store.publish(path, user_id, id, encryptor)
    [public_path, Base64.strict_encode64(encrypted_aes_key), Base64.strict_encode64(encrypted_aes_iv)]
  end
end
