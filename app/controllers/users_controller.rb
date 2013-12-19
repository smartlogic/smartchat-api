class UsersController < ApplicationController
  skip_before_filter :check_authorization

  def create
    user = UserService.create(user_attributes)
    render :json => user, :status => 201, :private_key => true
  end

  def sign_in
    email, password = Base64.decode64(request.headers["Authorization"].gsub("Basic ", "")).split(":")
    user = User.where(:email => email).first
    if user.password == password
      render :json => user, :status => 200, :private_key => true
    else
      render :json => {}, :status => 401
    end
  end

  def invite
    InvitationService.invite(params[:email], params[:message])

    head 204
  end

  private

  def user_attributes
    params.require(:user).permit(:email, :password, :phone)
  end
end
