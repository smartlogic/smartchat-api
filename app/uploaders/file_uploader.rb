class FileUploader < CarrierWave::Uploader::Base
  storage :file

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def store_dir
    Rails.root.join("tmp", "uploads", model.class.to_s.underscore, model.id.to_s)
  end
end
