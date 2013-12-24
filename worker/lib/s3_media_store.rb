class S3MediaStore
  def initialize(private_bucket, public_bucket)
    @private_bucket, @public_bucket = private_bucket, public_bucket
  end

  def publish(path, user_id, media_id, encryptor)
    private_object = @private_bucket.objects[path]
    encrypted_aes_key, encrypted_aes_iv, encrypted_data = encryptor.encrypt(private_object.read)

    public_file_path = "users/#{user_id}/media/#{media_id}/#{File.basename(path)}"
    object = @public_bucket.objects[public_file_path]
    object.write(encrypted_data)
    object.acl = :public_read

    [object.public_url, encrypted_aes_key, encrypted_aes_iv]
  end

  def read_once(path)
    object = @public_bucket.objects[path]
    data = object.read
    object.delete
    data
  end
end
