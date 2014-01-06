require 'redis'

RedisMessage = Struct.new(:body)

class RedisQueue
  def initialize
    @redis = Redis.new
  end

  def poll(&block)
    loop do
      if queue_size > 0
        message = @redis.rpop("smartchat-queue")
        block.call(RedisMessage.new(message))
      end

      sleep 1
    end
  end

  def send_message(message_json)
    @redis.lpush("smartchat-queue", message_json)
  end

  private

  def queue_size
    @redis.llen("smartchat-queue")
  end
end
