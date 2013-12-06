module NotificationService
  def notify(friend_id, media, user_klass = User, container = AppContainer)
    user = user_klass.find(friend_id)

    container.sqs_queue.send_message({
      "id" => media.id,
      "user_id" => friend_id,
      "public_key" => user.public_key,
      "created_at" => media.created_at,
      "file_path" => media.file.path,
      "devices" => [
        {
          "id" => user.device_id,
          "type" => user.device_type
        }
      ],
      "creator" => {
        "id" => media.user_id,
        "email" => media.user_email
      }
    }.to_json)
  end
  module_function :notify

  def send_notification_to_devices(device_notification_attrs, container)
    device_notification_attrs["devices"].each do |device|
      if device["device_type"] == "android"
        s3_file_url = "#{container.s3_host}#{device_notification_attrs["s3_file_path"]}"
        container.android_notifier.notify({
          "device_id" => device["device_id"],
          "message" => {
            "s3_file_url" => s3_file_url,
            "created_at" => device_notification_attrs["created_at"],
            "creator" => device_notification_attrs["creator"]
          }
        })
      end
    end
  end
  module_function :send_notification_to_devices
end
