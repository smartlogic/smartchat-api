require 'base64'

class SmartchatEncryptor
  def initialize(public_key_pem)
    @public_key_pem = public_key_pem
  end

  def encrypt(data)
    public_key = OpenSSL::PKey::RSA.new @public_key_pem

    cipher = OpenSSL::Cipher.new("AES-128-CBC")
    cipher.encrypt

    aes_key = cipher.random_key
    aes_iv = cipher.random_iv

    encrypted_aes_key = public_key.public_encrypt(aes_key)
    encrypted_aes_iv = public_key.public_encrypt(aes_iv)

    encrypted_data = cipher.update(data) + cipher.final

    [Base64.strict_encode64(encrypted_aes_key), Base64.strict_encode64(encrypted_aes_iv), encrypted_data]
  end
end
