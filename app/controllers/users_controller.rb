class UsersController < ApplicationController
  skip_before_filter :check_authorization

  def create
    user = UserService.create(user_attributes)
    render :json => user, :status => 201, :private_key => true
  end

  private

  def user_attributes
    params.require(:user).permit(:email, :password, :phone)
  end
end
