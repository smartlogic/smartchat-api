class TestEncryptor
  def encrypt(data)
    ["encrypted aes key", "encrypted aes iv", data.reverse]
  end
end

class TestNotificationService
  attr_accessor :notifications

  def initialize
    @notifications = []
  end

  def send_notification_to_devices(notification)
    @notifications << notification
  end
end

TestEncryptorFactory = Struct.new(:instance) do
  def new(public_key)
    instance
  end
end

class TestMediaStore
  def initialize(private_bucket = {})
    @private_bucket = private_bucket
    @public_bucket = {}
  end

  def publish(path, user_id, media_id, encryptor)
    encrypted_aes_key, encrypted_aes_iv, encrypted_data = encryptor.encrypt(@private_bucket.fetch(path))
    @public_bucket[path] = encrypted_data
    [path, encrypted_aes_key, encrypted_aes_iv]
  end

  def [](path)
    @public_bucket[path]
  end
end
