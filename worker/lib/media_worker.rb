require 'openssl'
require 'base64'

class MediaWorker
  def perform(media_attributes, container = AppContainer)
    notification_hash = {
      "creator" => media_attributes["creator"],
      "devices" => media_attributes["devices"],
      "created_at" => media_attributes["created_at"],
    }

    id = media_attributes["id"]
    user_id = media_attributes["user_id"]
    encryptor = container.smartchat_encryptor.new(media_attributes["public_key"])
    media_store = container.media_store

    file_path = media_attributes["file_path"]
    s3_file_path, encrypted_aes_key, encrypted_aes_iv =
      publish(file_path, user_id, id, encryptor, media_store)

    notification_hash = notification_hash.merge({
      "s3_file_path" => s3_file_path,
      "encrypted_aes_key" => encrypted_aes_key,
      "encrypted_aes_iv" => encrypted_aes_iv
    })

    if media_attributes["drawing_path"]
      drawing_file_path = media_attributes["drawing_path"]

      drawing_s3_file_path, drawing_encrypted_aes_key, drawing_encrypted_aes_iv =
        publish(drawing_file_path, user_id, id, encryptor, media_store)

      notification_hash = notification_hash.merge({
        "drawing_s3_file_path" => drawing_s3_file_path,
        "drawing_encrypted_aes_key" => drawing_encrypted_aes_key,
        "drawing_encrypted_aes_iv" => drawing_encrypted_aes_iv
      })
    end

    container.notification_service.send_notification_to_devices(notification_hash)
  end

  private

  def publish(path, user_id, id, encryptor, media_store)
    public_path, encrypted_aes_key, encrypted_aes_iv = media_store.publish(path, user_id, id, encryptor)
    [public_path, Base64.strict_encode64(encrypted_aes_key), Base64.strict_encode64(encrypted_aes_iv)]
  end
end
