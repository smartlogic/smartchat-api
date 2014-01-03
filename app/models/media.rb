class Media < ActiveRecord::Base
  belongs_to :poster, :class_name => "User"

  mount_uploader :file, FileUploader
  mount_uploader :drawing, FileUploader

  delegate :email, :to => :poster, :prefix => true

  def self.published
    where(:published => true)
  end
end
