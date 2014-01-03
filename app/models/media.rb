class Media < ActiveRecord::Base
  belongs_to :poster, :class_name => "User"

  delegate :email, :to => :poster, :prefix => true

  def self.published
    where(:published => true)
  end
end
