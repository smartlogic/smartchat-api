require 'openssl'

class MediaWorker
  def perform(media_attributes, file_klass = File, rsa_klass = OpenSSL::PKey::RSA, notification_service_klass = NotificationService, container = AppContainer)
    public_key = rsa_klass.new media_attributes["public_key"]
    encrypted_data = public_key.public_encrypt(file_klass.read(media_attributes["file_path"]))

    id = media_attributes["id"]
    user_id = media_attributes["user_id"]
    file_name = file_klass.basename(media_attributes["file_path"])
    s3_file_path = "users/#{user_id}/media/#{id}/#{file_name}"

    object = container.s3_bucket.objects[s3_file_path]
    object.write(encrypted_data)

    notification_service_klass.send_notification_to_devices({
      "creator" => media_attributes["creator"],
      "devices" => media_attributes["devices"],
      "s3_file_path" => s3_file_path,
      "created_at" => media_attributes["created_at"]
    })
  end
end
