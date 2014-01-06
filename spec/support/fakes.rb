class TestEncryptor
  def encrypt(data)
    ["encrypted aes key", "encrypted aes iv", data.reverse]
  end
end
