class S3MediaStore
  def initialize(private_bucket, published_bucket, base_uri)
    @private_bucket, @published_bucket, @base_uri = private_bucket, published_bucket, base_uri
  end

  def store(media_id, file_path)
    file = File.new(file_path)
    s3_file_path = "media/#{media_id}/#{File.basename(file)}"

    private_object = @private_bucket.objects[s3_file_path]
    private_object.write(file.read)

    s3_file_path
  end

  def publish(path, user_id, media_id, encryptor)
    private_object = @private_bucket.objects[path]
    encrypted_aes_key, encrypted_aes_iv, encrypted_data = encryptor.encrypt(private_object.read)

    published_file_path = "users/#{user_id}/media/#{media_id}/#{File.basename(path)}"
    object = @published_bucket.objects[published_file_path]
    object.write(encrypted_data)
    object.acl = :public_read

    private_object.delete

    [@base_uri + published_file_path, encrypted_aes_key, encrypted_aes_iv]
  end

  def read_once(path)
    object = @published_bucket.objects[path]

    if object.exists?
      data = object.read
      object.delete
    else
      data = nil
    end

    data
  end
end
