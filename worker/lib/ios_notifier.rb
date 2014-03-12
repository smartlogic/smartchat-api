require 'houston'

module IosNotifier
  def notify(notification_attrs, container = AppContainer)
    device_id = notification_attrs.fetch("device_id")
    message = notification_attrs.fetch("message")

    notification = Houston::Notification.new(:device => notification_attrs["device_id"])
    notification.sound = "sosumi.aiff"

    case message["type"]
    when "media"
      notification.alert = "New smartchat from #{message["creator_username"]}"
    when "friend-added"
      notification.alert = "#{message["groupie_username"]} added you!"
    end

    container.apn_connection.push(notification)
  end
  module_function :notify
end
