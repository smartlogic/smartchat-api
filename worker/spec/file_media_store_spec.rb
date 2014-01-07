require 'spec_helper'
require 'file_media_store'
require 'tmpdir'
require 'tempfile'

describe FileMediaStore do
  let(:base_uri) { URI::HTTP.build(:host => "example.com", :path => "/foo/") }
  let(:redis) { Redis::Namespace.new("smartchat-test", :redis => Redis.new) }

  it "should store a file" do
    Dir.mktmpdir do |tmpdir|
      tempfile = Tempfile.new("file")
      tempfile.write("data")
      tempfile.rewind

      store = FileMediaStore.new(Pathname.new(tmpdir), base_uri, redis)
      file_path = store.store(tempfile.path)

      expect(file_path).to match(/#{File.basename(tempfile)}$/)
      tempfile.unlink
    end
  end

  it "encryptes before publishing" do
    Dir.mktmpdir do |tmpdir|
      store = FileMediaStore.new(Pathname.new(tmpdir), base_uri, redis)
      encryptor = TestEncryptor.new

      file_path = store.store("spec/fixtures/file.txt")

      public_url = store.publish(file_path, "user_id", "folder", "file.png", encryptor, "extra-metadata" => "true")

      published_path = public_url - base_uri

      path = Pathname.new(tmpdir).join("published", published_path.to_s)
      expect(File.exists?(path)).to be_true
      expect(File.read(path)).to eq("\natad")

      metadata = JSON.parse(redis.get(published_path.to_s))
      expect(metadata["encrypted_aes_key"]).to eq("encrypted aes key")
      expect(metadata["encrypted_aes_iv"]).to eq("encrypted aes iv")
      expect(metadata["extra-metadata"]).to eq("true")
    end
  end

  it "should read once and delete the file" do
    Dir.mktmpdir do |tmpdir|
      tempfile = Tempfile.new("file")
      tempfile.write("data")
      tempfile.rewind

      store = FileMediaStore.new(Pathname.new(tmpdir), base_uri, redis)
      encryptor = TestEncryptor.new

      file_path = store.store(tempfile.path)
      public_url =
        store.publish(file_path, "user_id", "folder", "file.png", encryptor)
      published_path = public_url - base_uri

      data, aes_key, aes_iv = store.read_once(published_path.to_s)

      expect(data).to eq("atad")
      expect(aes_key).to eq("encrypted aes key")
      expect(aes_iv).to eq("encrypted aes iv")
    end
  end

  it "should list files for a particular user" do
    Dir.mktmpdir do |tmpdir|
      store = FileMediaStore.new(Pathname.new(tmpdir), base_uri, redis)
      encryptor = TestEncryptor.new

      file_path = store.store("spec/fixtures/file.txt")
      drawing_path = store.store("spec/fixtures/file.txt")
      store.publish(file_path, 1, "folder", "file.png", encryptor)
      store.publish(drawing_path, 1, "folder", "drawing.png", encryptor)

      expect(store.users_index(1)).to eq([
        Media.new("users/1/folder/file.png", "users/1/folder/drawing.png")
      ])
    end
  end
end
