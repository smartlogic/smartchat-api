require 'openssl'

module UserService
  CIPHER = 'AES-128-CBC'

  def create(user_attributes, user_klass = User, pk_klass = OpenSSL::PKey::RSA, cipher_klass = OpenSSL::Cipher)
    user = user_klass.new(user_attributes)

    hashed_password = user_klass.hash_password_for_private_key(user_attributes[:password].to_s)
    key = pk_klass.new 2048
    cipher = cipher_klass.new CIPHER

    user.private_key = key.export(cipher, hashed_password)
    user.public_key = key.public_key.to_pem
    user.save

    user
  end
  module_function :create
end
