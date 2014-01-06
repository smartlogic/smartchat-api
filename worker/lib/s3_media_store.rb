class S3MediaStore
  def initialize(private_bucket, published_bucket, base_uri)
    @private_bucket, @published_bucket, @base_uri = private_bucket, published_bucket, base_uri
  end

  def store(file_path)
    file = File.new(file_path)
    s3_file_path = "#{SecureRandom.hex}/#{File.basename(file)}"

    private_object = @private_bucket.objects[s3_file_path]
    private_object.write(file.read)

    s3_file_path
  end

  def publish(path, user_id, media_id, encryptor)
    private_object = @private_bucket.objects[path]
    encrypted_aes_key, encrypted_aes_iv, encrypted_data = encryptor.encrypt(private_object.read)

    published_file_path = "users/#{user_id}/media/#{media_id}/#{File.basename(path)}"
    object = @published_bucket.objects[published_file_path]
    object.write(encrypted_data, :metadata => {
      "encrypted_aes_key" => encrypted_aes_key,
      "encrypted_aes_iv" => encrypted_aes_iv
    })

    private_object.delete

    @base_uri + published_file_path
  end

  def read_once(path)
    object = @published_bucket.objects[path]

    if object.exists?
      data = object.read
      key = object.metadata["encrypted_aes_key"]
      iv = object.metadata["encrypted_aes_iv"]
      object.delete
    end

    [data, key, iv]
  end
end
