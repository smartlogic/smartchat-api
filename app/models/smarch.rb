class Smarch < ActiveRecord::Base
  store_accessor :document, :friend_ids

  belongs_to :creator, :class_name => "User"
end
