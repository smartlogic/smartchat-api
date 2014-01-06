require 'spec_helper'

describe SmartchatEncryptor do
  let(:key) { OpenSSL::PKey::RSA.new 512 }
  let(:public_key_pem) { key.public_key.to_pem }

  it "should encrypt data passed in" do
    encryptor = SmartchatEncryptor.new(public_key_pem)
    encrypted_key, encrypted_iv, encrypted_data = encryptor.encrypt("this data")

    aes_key = key.private_decrypt(Base64.strict_decode64(encrypted_key))
    aes_iv = key.private_decrypt(Base64.strict_decode64(encrypted_iv))

    cipher = OpenSSL::Cipher.new("AES-128-CBC")
    cipher.decrypt
    cipher.key = aes_key
    cipher.iv = aes_iv

    data = cipher.update(encrypted_data) + cipher.final

    expect(data).to eq("this data")
  end
end
