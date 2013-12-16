module NotificationService
  def send_notification_to_devices(device_notification_attrs, container = AppContainer)
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
