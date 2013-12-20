require 'openssl'
require 'base64'

class MediaWorker
  def perform(media_attributes, file_klass = File, notification_service_klass = NotificationService, container = AppContainer)
    private_object = container.s3_private_bucket.objects[media_attributes["file_path"]]

    encryptor = container.smartchat_encryptor.new(media_attributes["public_key"])
    encrypted_aes_key, encrypted_aes_iv, encrypted_data =
      encryptor.encrypt(private_object.read)

    id = media_attributes["id"]
    user_id = media_attributes["user_id"]
    file_name = file_klass.basename(media_attributes["file_path"])
    s3_file_path = "users/#{user_id}/media/#{id}/#{file_name}"

    object = container.s3_bucket.objects[s3_file_path]
    object.write(encrypted_data)
    object.acl = :public_read

    notification_service_klass.send_notification_to_devices({
      "creator" => media_attributes["creator"],
      "devices" => media_attributes["devices"],
      "s3_file_path" => s3_file_path,
      "created_at" => media_attributes["created_at"],
      "encrypted_aes_key" => Base64.strict_encode64(encrypted_aes_key),
      "encrypted_aes_iv" => Base64.strict_encode64(encrypted_aes_iv)
    })
  end
end
