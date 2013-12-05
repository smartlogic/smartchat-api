module NotificationService
  def notify(friend_id, media, user_klass = User, container = AppContainer)
    user = user_klass.find(friend_id)

    container.sqs_queue.send_message({
      :public_key => user.public_key,
      :created_at => media.created_at,
      :file => media.file.path,
      :user => {
        :email => media.user.email
      }
    }.to_json)
  end
  module_function :notify
end
