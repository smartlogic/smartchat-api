module NotificationService
  def notify(friend_id, media, user_klass = User, container = AppContainer)
    user = user_klass.find(friend_id)

    container.sqs_queue.send_message({
      "id" => media.id,
      "user_id" => friend_id,
      "public_key" => user.public_key,
      "created_at" => media.created_at,
      "file_path" => media.file.path,
      "creator" => {
        "id" => media.user.id,
        "email" => media.user.email
      }
    }.to_json)
  end
  module_function :notify

  def create(*args)
  end
  module_function :create
end
