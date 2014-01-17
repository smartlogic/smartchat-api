class CleanUpWorker
  def perform(body, container = AppContainer)
    user = body.fetch("user_id")
    timestamp = Time.parse(body.fetch("timestamp"))

    container.media_store.clean_up_user!(user, timestamp)
  end
end
