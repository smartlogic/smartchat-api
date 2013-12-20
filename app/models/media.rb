class Media < ActiveRecord::Base
  belongs_to :user

  mount_uploader :file, FileUploader
  mount_uploader :drawing, FileUploader

  delegate :id, :email, :to => :user, :prefix => true
end
