def create_user(attrs = {})
  UserService.create({
    :username => "eric",
    :email => "eric@example.com",
    :password => "password"
  }.merge(attrs))
end
