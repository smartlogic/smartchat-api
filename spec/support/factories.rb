def create_user(attrs = {})
  UserService.create({
    :username => "eric",
    :email => "eric@example.com",
    :password => "password",
    :phone_number => "123-123-1234"
  }.merge(attrs))
end
