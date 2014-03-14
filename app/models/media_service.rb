module MediaService
  DEFAULT_EXPIRE_IN = 10

  def create(user, friend_ids, file_path, drawing_path, expire_in = DEFAULT_EXPIRE_IN)
    uuid = Smarch.create({
      :creator_id => user.id,
      :friend_ids => friend_ids
    }).id
    Worker.perform_async(uuid, user.id, user.username, friend_ids, file_path, drawing_path, expire_in)
    uuid
  end
  module_function :create

  class Worker
    include Sidekiq::Worker

    sidekiq_options :retry => 5

    def perform(uuid, user_id, user_username, friend_ids, file_path, drawing_path, expire_in)
      friend_ids.each do |friend_id|
        file_key = AppContainer.media_store.store(file_path)

        if drawing_path
          drawing_key = AppContainer.media_store.store(drawing_path)
        end

        AppContainer.notification_service.notify(friend_id, {
          "uuid" => uuid,
          "poster_id" => user_id,
          "poster_username" => user_username,
          "file" => file_key,
          "drawing" => drawing_key,
          "created_at" => Time.now,
          "expire_in" => expire_in,
          "pending" => !AppContainer.friend_service.friends_with_user?(friend_id, user_id)
        })
      end

      File.unlink(file_path)
      File.unlink(drawing_path) if drawing_path
    end
  end
end
