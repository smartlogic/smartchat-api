require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  has_one :device

  delegate :device_id, :device_type, :to => :device

  def self.hash_password_for_private_key(password, sha_klass = OpenSSL::Digest::SHA256)
    sha256 = sha_klass.new

    1000.times.inject(password) do |hash, _|
      sha256.hexdigest(hash)
    end
  end

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end
end
