require 'spec_helper'

describe S3MediaStore do
  let(:published_bucket) { AppContainer.s3_published_bucket }
  let(:private_bucket) { AppContainer.s3_private_bucket }
  let(:base_uri) { URI::HTTP.build(:host => "example.com", :path => "/foo/") }

  it "encrypts before publishing" do
    path = SecureRandom.hex
    private_bucket.objects[path].write("data")

    store = S3MediaStore.new(private_bucket, published_bucket, base_uri)
    encryptor = TestEncryptor.new

    public_url, key, iv = store.publish(path, "user_id", "media_id", encryptor)

    published_path = public_url - base_uri
    published_object = published_bucket.objects[published_path]

    expect(published_object.read).to eq("atad")
  end

  it "should read once and delete the file" do
    path = SecureRandom.hex
    published_bucket.objects[path].write("data")

    store = S3MediaStore.new(private_bucket, published_bucket, base_uri)
    data = store.read_once(path)

    expect(data).to eq("data")
    expect(published_bucket.objects[path].exists?).to be_false
  end
end
