class Smarch < ActiveRecord::Base
  store_accessor :document, :creator_id, :friend_ids
end
