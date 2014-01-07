require 'media'

class FileMediaStore
  def initialize(directory, base_uri)
    @file_metadata = {}
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

  def publish(path, user_id, folder, file_name, encryptor)
    file = File.new(@private_directory.join(path))
    encrypted_aes_key, encrypted_aes_iv, encrypted_data = encryptor.encrypt(file.read)

    published_folder = "users/#{user_id}/#{folder}"
    published_file_path = "#{published_folder}/#{file_name}"
    FileUtils.mkdir_p @published_directory.join(published_folder)
    published_file = File.new(@published_directory.join(published_file_path), "w")
    published_file.write(encrypted_data)
    published_file.close
    @file_metadata[published_file_path] = {
      "encrypted_aes_key" => encrypted_aes_key,
      "encrypted_aes_iv" => encrypted_aes_iv
    }

    File.delete(file)

    @base_uri + published_file_path
  end

  def read_once(path)
    file = File.new(@published_directory.join(path))

    if File.exists?(file)
      data = file.read
      key = @file_metadata[path]["encrypted_aes_key"]
      iv = @file_metadata[path]["encrypted_aes_iv"]
      File.delete(file)
    end

    [data, key, iv]
  end

  def users_index(user_id)
    folders = Hash.new({})
    @file_metadata.each do |file_path, metadata|
      folder = file_path.split("/")[2]
      if file_path =~ /file/
        key = :file_path
      else
        key = :drawing_path
      end
      folders[folder] = folders[folder].merge(key => file_path)
    end

    folders.map do |key, files|
      Media.new(files[:file_path], files[:drawing_path])
    end
  end
end
