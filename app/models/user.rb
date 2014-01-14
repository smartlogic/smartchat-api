require 'bcrypt'

class User < ActiveRecord::Base
  include BCrypt

  validates :email, :presence => true,
    :uniqueness => true,
    :format => {
      :with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/,
      :message => "not an email address", :allow_nil => true
    }
  validates :password, :presence => true

  has_one :device

  delegate :device_id, :device_type, :to => :device

  def self.hash_password_for_private_key(password, sha_klass = OpenSSL::Digest::SHA256)
    sha256 = sha_klass.new

    1000.times.inject(password) do |hash, _|
      sha256.hexdigest(hash)
    end
  end

  def self.with_hashed_phone_numbers(phone_numbers)
    select("*").select("true as found_by_phone").where("md5(phone_number) in (?)", phone_numbers)
  end

  def self.with_hashed_emails(emails)
    select("*").select("true as found_by_email").where("md5(email) in (?)", emails)
  end

  def self.excluding_friends(user)
    users = FriendService.find_friends(user).compact
    if users.present?
      where("id not in (?)", users.map(&:id))
    else
      all
    end
  end

  def password
    return unless password_hash
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    return if new_password.blank?
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def phone_number=(new_phone_number)
    self[:phone_number] = new_phone_number

    if phone_number.present?
      self[:phone_number] = phone_number.gsub(/[^\d]/, "")
    end

    phone_number
  end

  def device_destroy
    if device
      device.destroy
      self.device = nil
    end
  end
end
