module NotificationService
  def send_notification_to_devices(devices, notification, container = AppContainer)
    DaemonKit.logger.debug "Sending notification to #{devices.count} devices"

    devices.each do |device|
      if device["device_type"] == "android"
        container.android_notifier.notify({
          "device_id" => device["device_id"],
          "message" => notification
        })
      elsif device["device_type"] == "iOS"
        container.ios_notifier.notify({
          "device_id" => device["device_id"],
          "message" => notification
        })
      end
    end
  end
  module_function :send_notification_to_devices
end
