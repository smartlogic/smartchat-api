require 'spec_helper'

describe User do
  it "should hash a password a bunch" do
    sha_double = double(:sha256)
    expect(sha_double).to receive(:new).and_return(sha_double)
    expect(sha_double).to receive(:hexdigest).exactly(1000).times.
      and_return("hexdigest")

    expect(User.hash_password_for_private_key("password", sha_double)).to eq("hexdigest")
  end

  it "should encrypt the password" do
    subject.password = "hi"
    expect(subject.password_hash).to_not be_empty
    expect(subject.password).to eq("hi")
  end

  it "should remove all non numerical characters when setting a phone_number number" do
    subject.phone_number = "(123) 555-1234"
    expect(subject.phone_number).to eq("1235551234")

    subject.phone_number = nil
    expect(subject.phone_number).to be_nil
  end

  it "should not allow another user with the same email" do
    UserService.create({
      :username => "eric",
      :email => "eric@example.com",
      :password => "password",
    })

    subject.email = "eric@example.com"
    expect(subject).to have(1).error_on(:email)
  end

  it "should not allow another user with the same username" do
    UserService.create({
      :username => "eric",
      :email => "eric@example.com",
      :password => "password",
    })

    subject.username = "eric"
    expect(subject).to have(1).error_on(:username)
  end

  context "it should destroy the current device" do
    it "exists" do
      user = User.new
      user.device = Device.new

      user.device_destroy

      expect(user.device).to be_nil
    end

    it "does not exist" do
      user = User.new

      user.device_destroy

      expect(user.device).to be_nil
    end
  end

  context "phone number verification" do
    it "should be verified" do
      user = User.new(:phone_number => "1231231234")
      expect(user).to be_phone_number_verified
    end

    it "should not be verified" do
      user = User.new
      expect(user).to_not be_phone_number_verified
    end
  end

  it "should generate an sms verification code" do
    user = User.new
    user.generate_sms_verification_code
    expect(user.sms_verification_code).to_not be_empty
  end
end
