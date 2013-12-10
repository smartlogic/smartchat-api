require 'spec_helper'

describe UserService do
  let(:user_attributes) { {
    :email => "eric@example.com",
    :password => "password",
    :phone => "123-123-1234"
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
    expect(user_double).to receive(:phone=).with("1231231234")
    expect(user_double).to receive(:save!)

    UserService.create(user_attributes, user_klass_double)
  end
end
