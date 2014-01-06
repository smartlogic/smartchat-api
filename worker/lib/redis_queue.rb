require 'redis'

RedisMessage = Struct.new(:body)

class RedisQueue
  def initialize
    @redis = Redis.new
  end

  def poll(&block)
    loop do
      queue, message = @redis.brpop("smartchat-queue")
      # queue could be nil if a timeout happened
      if queue
        block.call(RedisMessage.new(message))
      end
    end
  end

  def send_message(message_json)
    @redis.lpush("smartchat-queue", message_json)
  end
end
