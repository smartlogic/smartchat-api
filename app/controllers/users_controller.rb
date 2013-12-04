class UsersController < ApplicationController
  def create
    user = UserService.create(user_attributes)
    render :json => user, :status => 201
  end

  private

  def user_attributes
    params.require(:user).permit(:email, :password, :phone)
  end
end
