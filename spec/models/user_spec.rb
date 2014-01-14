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

  it "should remove all non numerical characters when setting a phone number" do
    subject.phone = "(123) 555-1234"
    expect(subject.phone).to eq("1235551234")

    subject.phone = nil
    expect(subject.phone).to be_nil
  end

  it "should not allow another user with the same email" do
    UserService.create(:email => "eric@example.com", :password => "password", :phone => "123")

    subject.email = "eric@example.com"
    expect(subject).to have(1).error_on(:email)
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
end
