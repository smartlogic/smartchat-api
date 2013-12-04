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
end
