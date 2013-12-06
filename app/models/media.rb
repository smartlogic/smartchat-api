class Media < ActiveRecord::Base
  belongs_to :user

  mount_uploader :file, FileUploader

  delegate :id, :email, :to => :user, :prefix => true
end
