require 'media'

class FileMediaStore
  def initialize(directory, base_uri, redis)
    @redis = redis
    @private_directory, @published_directory = directory.join("private"), directory.join("published")
    @base_uri = base_uri

    FileUtils.mkdir_p @private_directory
    FileUtils.mkdir_p @published_directory
  end

  def store(file_path)
    folder = @private_directory.join(SecureRandom.hex)
    FileUtils.mkdir_p folder
    dest_path = folder.join(Pathname.new(file_path).basename)
    FileUtils.cp(file_path, dest_path)
    dest_path.relative_path_from(@private_directory).to_s
  end

  def publish(path, user_id, folder, file_name, encryptor, metadata = {})
    file = File.new(@private_directory.join(path))
    encrypted_aes_key, encrypted_aes_iv, encrypted_data = encryptor.encrypt(file.read)

    published_folder = "users/#{user_id}/#{folder}"
    published_file_path = "#{published_folder}/#{file_name}"
    FileUtils.mkdir_p @published_directory.join(published_folder)
    published_file = File.new(@published_directory.join(published_file_path), "w")
    published_file.write(encrypted_data)
    published_file.close
    @redis.sadd("smartchat-files", published_file_path)
    @redis.set(published_file_path, metadata.merge({
      "encrypted_aes_key" => encrypted_aes_key,
      "encrypted_aes_iv" => encrypted_aes_iv
    }).to_json)

    File.delete(file)

    @base_uri + published_file_path
  end

  def read_once(path)
    file = File.new(@published_directory.join(path))

    if File.exists?(file)
      data = file.read
      metadata = JSON.parse(@redis.get(path))
      key = metadata.delete("encrypted_aes_key")
      iv = metadata.delete("encrypted_aes_iv")
      @redis.srem("smartchat-files", path)
      @redis.del(path)
      File.delete(file)
    end

    [data, key, iv, metadata]
  end

  def users_index(user_id)
    folders = Hash.new({})
    @redis.smembers("smartchat-files").each do |file_path|
      folder = file_path.split("/")[2]
      if file_path =~ /file/
        key = :file_path
        folders[folder] = folders[folder].merge(:metadata => metadata_for(file_path))
      else
        key = :drawing_path
      end
      folders[folder] = folders[folder].merge(key => file_path)
    end

    folders.map do |key, files|
      Media.new(files[:file_path], files[:drawing_path], files[:metadata])
    end
  end

  private

  def metadata_for(key)
    metadata = JSON.parse(@redis.get(key))
    metadata.delete("encrypted_aes_key")
    metadata.delete("encrypted_aes_iv")
    metadata
  end
end
