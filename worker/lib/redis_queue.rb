require 'redis'

RedisMessage = Struct.new(:body)

class RedisQueue
  def initialize
    @redis = Redis.new
  end

  def poll(&block)
    loop do
      _, message = @redis.brpop("smartchat-queue")
      block.call(RedisMessage.new(message))
    end
  end

  def send_message(message_json)
    @redis.lpush("smartchat-queue", message_json)
  end
end
