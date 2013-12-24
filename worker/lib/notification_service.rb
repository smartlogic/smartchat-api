module NotificationService
  def send_notification_to_devices(device_notification_attrs, container = AppContainer)
    notification_message = {
      "created_at" => device_notification_attrs["created_at"],
      "creator_id" => device_notification_attrs["creator"]["id"],
      "creator_email" => device_notification_attrs["creator"]["email"],

      "file_url" => "#{container.s3_host}#{device_notification_attrs["file_path"]}",
      "encrypted_aes_key" => device_notification_attrs["encrypted_aes_key"],
      "encrypted_aes_iv" => device_notification_attrs["encrypted_aes_iv"],
    }

    if device_notification_attrs.has_key?("drawing_file_path")
      notification_message = notification_message.merge({
        "drawing_file_url" => "#{container.s3_host}#{device_notification_attrs["drawing_file_path"]}",
        "drawing_encrypted_aes_key" => device_notification_attrs["drawing_encrypted_aes_key"],
        "drawing_encrypted_aes_iv" => device_notification_attrs["drawing_encrypted_aes_iv"]
      })
    end

    device_notification_attrs["devices"].each do |device|
      if device["device_type"] == "android"
        container.android_notifier.notify({
          "device_id" => device["device_id"],
          "message" => notification_message
        })
      end
    end
  end
  module_function :send_notification_to_devices
end
