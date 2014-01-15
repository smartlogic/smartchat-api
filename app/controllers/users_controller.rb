class UsersController < ApplicationController
  skip_before_filter :check_authorization, :only => [:create, :sign_in]

  def create
    user = UserService.create(user_attributes)

    if user.persisted?
      render :json => user, :status => 201, :private_key => true
    else
      render :json => user.errors, :status => 422, :serializer => UserErrorSerializer
    end
  end

  def sign_in
    username, password = Base64.decode64(request.headers["Authorization"].gsub("Basic ", "")).split(":")
    user = User.where(:username => username).first
    if user && user.password == password
      render :json => user, :status => 200, :private_key => true
    else
      render :json => {}, :status => 401
    end
  end

  def invite
    InvitationService.invite(current_user.email, params[:email], params[:message])

    head 204
  end

  private

  def user_attributes
    params.require(:user).permit(:username, :email, :password, :phone_number)
  end
end
