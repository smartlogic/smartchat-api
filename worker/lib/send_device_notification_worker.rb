class SendDeviceNotificationWorker
  def perform(body, container = AppContainer)
    devices = body.fetch("devices")
    notification = body.fetch("message")

    container.notification_service.send_notification_to_devices(devices, notification)
  end
end
