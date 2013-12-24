require 'spec_helper'
require 'open-uri'

describe S3MediaStore do
  let(:public_bucket) { AppContainer.s3_bucket }
  let(:private_bucket) { AppContainer.s3_private_bucket }

  it "encrypts before publishing" do
    path = SecureRandom.hex
    private_bucket.objects[path].write("data")

    store = S3MediaStore.new(private_bucket, public_bucket)
    encryptor = TestEncryptor.new

    public_url, key, iv = store.publish(path, "user_id", "media_id", encryptor)

    expect(open(public_url).read).to eq("atad")
  end

  it "should read once and delete the file" do
    path = SecureRandom.hex
    public_bucket.objects[path].write("data")

    store = S3MediaStore.new(private_bucket, public_bucket)
    data = store.read_once(path)

    expect(data).to eq("data")
    expect(public_bucket.objects[path].exists?).to be_false
  end
end
