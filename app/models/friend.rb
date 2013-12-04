# NOTE: Nothing outside of FriendService should use this class
# as it might migrate outside of postgres
class Friend < ActiveRecord::Base
  belongs_to :from, :class_name => "User"
  belongs_to :to, :class_name => "User"
end
