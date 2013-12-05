class Media < ActiveRecord::Base
  mount_uploader :file, FileUploader
end
