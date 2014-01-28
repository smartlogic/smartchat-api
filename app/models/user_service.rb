require 'openssl'

module UserService
  CIPHER = 'AES-128-CBC'
  VERIFICATION_REGEX = / - ([a-f\d]{8})$/

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

  def verify_sms(phone_number, sms_body)
    match_data = VERIFICATION_REGEX.match(sms_body)

    return unless match_data

    code = match_data.captures.first
    user = User.find_verification_code(code)

    return unless user

    user.sms_verification_code = nil
    user.phone_number = phone_number
    user.save
  end
  module_function :verify_sms
end
