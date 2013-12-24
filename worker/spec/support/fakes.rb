class TestEncryptor
  attr_reader :data

  def initialize
    @data = []
  end

  def encrypt(data)
    @data << data

    ["encrypted aes key", "encrypted aes iv", "encrypted data"]
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
