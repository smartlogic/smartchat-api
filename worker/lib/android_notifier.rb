module AndroidNotifier
  def notify(notification_attrs, faraday_klass = Faraday, container = AppContainer)
    connection = faraday_klass.new({
      :url => "https://android.googleapis.com/"
    })

    connection.post("/gcm/send") do |conn|
      conn.headers["Content-Type"] = "application/json"
      conn.headers["Authorization"] = "key=#{container.gcm_api_key}"
      conn.body = {
        registration_ids: [notification_attrs["device_id"]],
        data: notification_attrs["message"]
      }.to_json
    end
  end
  module_function :notify
end
