module MediaService
  DEFAULT_EXPIRE_IN = 10

  def create(user, friend_ids, file_path, drawing_path, expire_in = DEFAULT_EXPIRE_IN)
    Worker.perform_async(user.id, user.username, friend_ids, file_path, drawing_path, expire_in)
  end
  module_function :create

  class Worker
    include Sidekiq::Worker

    def perform(user_id, user_username, friend_ids, file_path, drawing_path, expire_in)
      friend_ids.each do |friend_id|
        unless AppContainer.friend_service.friends_with_user?(friend_id, user_id)
          next
        end

        file_key = AppContainer.media_store.store(file_path)

        if drawing_path
          drawing_key = AppContainer.media_store.store(drawing_path)
        end

        AppContainer.notification_service.notify(friend_id, {
          "poster_id" => user_id,
          "poster_username" => user_username,
          "file" => file_key,
          "drawing" => drawing_key,
          "created_at" => Time.now,
          "expire_in" => expire_in
        })
      end

      File.unlink(file_path)
      File.unlink(drawing_path) if drawing_path
    end
  end
end
