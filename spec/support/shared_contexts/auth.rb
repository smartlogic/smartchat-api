shared_context :auth do
  header "Authorization", :auth_header

  let!(:user) do
    UserService.create({
      :email => "eric@example.com",
      :password => "password",
      :phone => "123-123-1234"
    })
  end

  let(:private_key) do
    OpenSSL::PKey::RSA.new user.private_key, User.hash_password_for_private_key("password")
  end

  let(:auth_header) do
    sign_header(private_key, "eric@example.com", "http://example.org#{path}")
  end

  def sign_header(private_key, email, url)
    digest = OpenSSL::Digest::SHA256.new
    signed_base64 = Base64.encode64(private_key.sign(digest, url))
    user_string = "#{email}:#{signed_base64}"
    "Basic #{Base64.encode64(user_string)}"
  end
end
