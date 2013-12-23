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

    private_object = container.s3_private_bucket.objects[media_attributes["file_path"]]
    encryptor = container.smartchat_encryptor.new(media_attributes["public_key"])
    encrypted_aes_key, encrypted_aes_iv, encrypted_data =
      encryptor.encrypt(private_object.read)

    s3_file_path = "users/#{user_id}/media/#{id}/#{File.basename(media_attributes["file_path"])}"
    upload(container, s3_file_path, encrypted_data)

    notification_hash = notification_hash.merge({
      "s3_file_path" => s3_file_path,
      "encrypted_aes_key" => Base64.strict_encode64(encrypted_aes_key),
      "encrypted_aes_iv" => Base64.strict_encode64(encrypted_aes_iv),
    })

    if media_attributes["drawing_path"]
      drawing_private_object = container.s3_private_bucket.objects[media_attributes["drawing_path"]]
      encryptor = container.smartchat_encryptor.new(media_attributes["public_key"])
      drawing_encrypted_aes_key, drawing_encrypted_aes_iv, drawing_encrypted_data =
        encryptor.encrypt(drawing_private_object.read)

      drawing_s3_file_path = "users/#{user_id}/media/#{id}/drawing.png"
      upload(container, drawing_s3_file_path, drawing_encrypted_data)

      notification_hash = notification_hash.merge({
        "drawing_s3_file_path" => drawing_s3_file_path,
        "drawing_encrypted_aes_key" => Base64.strict_encode64(drawing_encrypted_aes_key),
        "drawing_encrypted_aes_iv" => Base64.strict_encode64(drawing_encrypted_aes_iv)
      })
    end

    container.notification_service.send_notification_to_devices(notification_hash)
  end

  private

  def upload(container, s3_file_path, data)
    object = container.s3_bucket.objects[s3_file_path]
    object.write(data)
    object.acl = :public_read
  end
end
