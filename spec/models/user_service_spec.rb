require 'spec_helper'

describe UserService do
  let(:user_attributes) { {
    :email => "eric@example.com",
    :password => "password"
  } }

  it "should create a new user" do
    user_klass_double = double(:User)
    user_double = double(:user)

    expect(user_klass_double).to receive(:new).with(user_attributes).
      and_return(user_double)
    expect(user_klass_double).to receive(:hash_password_for_private_key).with("password").
      and_return("a hashed password")

    expect(user_double).to receive(:private_key=)
    expect(user_double).to receive(:public_key=)
    expect(user_double).to receive(:save)

    UserService.create(user_attributes, user_klass_double)
  end

  context "sms verification" do
    it "should verify the sms phone number" do
      user = create_user
      user.update(:sms_verification_code => "abcd1234")

      expect(UserService.verify_sms("+11231231234", "Body of text - abcd1234")).to be_true

      user.reload
      expect(user).to be_phone_number_verified
      expect(user.phone_number).to eq("1231231234")
      expect(user.sms_verification_code).to be_nil
    end

    it "should reject a bad verification code" do
      expect(UserService.verify_sms("+11231231234", "Body of text - abcd1234")).to be_false
    end

    it "should reject a message with no verification code" do
      expect(UserService.verify_sms("+11231231234", "Body of text - abcd134")).to be_false
      expect(UserService.verify_sms("+11231231234", "Body of text  abcd134")).to be_false
      expect(UserService.verify_sms("+11231231234", "Body of text")).to be_false
    end
  end
end
