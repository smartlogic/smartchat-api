class FileUploader < CarrierWave::Uploader::Base
  @fog_public = false

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def store_dir
    File.join("uploads", model.class.to_s.underscore, model.id.to_s)
  end
end
