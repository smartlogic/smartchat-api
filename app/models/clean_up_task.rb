class CleanUpTask
  def self.perform(container)
    User.pluck(:id).each do |user_id|
      container.queue.send_message({
        "queue" => "clean-up",
        "user_id" => user_id,
        "timestamp" => container.clean_up_limit.call
      }.to_json)
    end
  end
end
