["eric", "sam", "yair", "paul", "tom"].each do |user|
  UserService.create({
    :username => user,
    :email => "#{user}@example.com",
    :password => "password"
  })
end

User.all.each do |user|
  User.all.each do |friend|
    FriendService.create(user, friend)
  end
end
