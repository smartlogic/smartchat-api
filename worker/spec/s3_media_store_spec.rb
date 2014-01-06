require 'spec_helper'
require 'tempfile'

describe S3MediaStore do
  let(:published_bucket) { AppContainer.s3_published_bucket }
  let(:private_bucket) { AppContainer.s3_private_bucket }
  let(:base_uri) { URI::HTTP.build(:host => "example.com", :path => "/foo/") }

  it "should store a file" do
    tempfile = Tempfile.new("file")
    tempfile.write("data")
    tempfile.rewind

    store = S3MediaStore.new(private_bucket, published_bucket, base_uri)
    file_path = store.store(tempfile.path)

    expect(file_path).to match(/#{File.basename(tempfile)}$/)
    object = private_bucket.objects[file_path]
    expect(object.read).to eq("data")

    object.delete
    tempfile.unlink
  end

  it "encrypts before publishing" do
    path = SecureRandom.hex
    private_object = private_bucket.objects[path]
    private_object.write("data")

    store = S3MediaStore.new(private_bucket, published_bucket, base_uri)
    encryptor = TestEncryptor.new

    public_url = store.publish(path, "user_id", "folder", "file.png", encryptor)

    published_path = public_url - base_uri
    published_object = published_bucket.objects[published_path]

    expect(published_object.read).to eq("atad")
    expect(published_object.metadata["encrypted_aes_key"]).to eq("encrypted aes key")
    expect(published_object.metadata["encrypted_aes_iv"]).to eq("encrypted aes iv")
    expect(private_object.exists?).to be_false
  end

  it "should read once and delete the file" do
    path = SecureRandom.hex
    published_bucket.objects[path].write("data", :metadata => {
      "encrypted_aes_key" => "key",
      "encrypted_aes_iv" => "iv",
    })

    store = S3MediaStore.new(private_bucket, published_bucket, base_uri)
    data, aes_key, aes_iv = store.read_once(path)

    expect(data).to eq("data")
    expect(aes_key).to eq("key")
    expect(aes_iv).to eq("iv")
    expect(published_bucket.objects[path].exists?).to be_false
  end

  it "should return nil if the path is not in the published bucket" do
    path = SecureRandom.hex

    store = S3MediaStore.new(private_bucket, published_bucket, base_uri)
    data, aes_key, aes_iv = store.read_once(path)

    expect(data).to be_nil
  end

  it "should list files for a particular user" do
    encryptor = TestEncryptor.new
    store = S3MediaStore.new(private_bucket, published_bucket, base_uri)

    file_path = store.store("spec/fixtures/file.txt")
    drawing_path = store.store("spec/fixtures/file.txt")

    store.publish(file_path, 1, "folder", "file.png", encryptor)
    store.publish(drawing_path, 1, "folder", "drawing.png", encryptor)

    expect(store.users_index(1)).to eq([
      Media.new("users/1/folder/file.png", "users/1/folder/drawing.png")
    ])
  end
end
