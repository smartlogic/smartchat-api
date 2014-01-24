class ApplicationController < ActionController::Base
  before_filter :check_authorization

  private

  def current_user
    @current_user
  end

  def check_authorization
    return unless request.headers["Authorization"]

    username, signed_path = Base64.decode64(request.headers["Authorization"].gsub("Basic ", "")).split(":")
    signed_path = Base64.decode64(signed_path)

    user = User.where(:username => username).first

    unless user
      Rails.logger.info("User not found")
      render :text => "", :status => 401
      return
    end

    public_key = OpenSSL::PKey::RSA.new user.public_key

    if public_key.verify OpenSSL::Digest::SHA256.new, signed_path, request.original_url
      @current_user = user
    else
      Rails.logger.info("Bad signature")
      render :text => "", :status => 401
    end
  end
end
