class Configuration
  def initialize(redis)
    @redis = redis
  end

  KEYS = [
    :aws_access_key_id,
    :aws_secret_access_key,
    :aws_region,
    :aws_smtp_username,
    :aws_smtp_password,
    :gcm_api_key,
    :twilio_account_sid,
    :twilio_verification_phone_number,
    :sidekiq_web_password
  ]

  def to_h
    KEYS.inject({}) do |hash, key|
      hash.merge(key => @redis.get(key))
    end
  end
end
