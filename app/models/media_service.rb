module MediaService
  def create(user, friend_ids, file_path, drawing_path)
    Worker.perform_async(user.id, friend_ids, file_path, drawing_path)
  end
  module_function :create

  class Worker
    include Sidekiq::Worker

    def perform(user_id, friend_ids, file_path, drawing_path)
      file = File.open(file_path)

      if drawing_path
        drawing = File.open(drawing_path)
      end

      friend_ids.each do |friend_id|
        media = Media.create!({
          "user_id" => friend_id,
          "poster_id" => user_id,
          "file" => file,
          "drawing" => drawing
        })
        AppContainer.notification_service.notify(friend_id, media)
      end

      File.unlink(file_path)
      File.unlink(drawing_path) if drawing_path
    end
  end
end
