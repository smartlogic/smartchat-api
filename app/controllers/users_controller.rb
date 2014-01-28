class UsersController < ApplicationController
  skip_before_filter :check_authorization, :only => [:create, :sign_in]

  before_filter :verify_twilio_account, :only => :sms_confirm

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

  def sms_verify
    current_user.generate_sms_verification_code
    render :json => current_user, :serializer => SmsVerifySerializer
  end

  def sms_confirm
    if UserService.verify_sms(params[:From], params[:Body])
      render :xml => <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<Response>
  <Sms>
    Your phone number has been verified.
  </Sms>
</Response>
      XML
    else
      render :status => 422, :xml => <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<Response>
</Response>
      XML
    end
  end

  private

  def user_attributes
    params.require(:user).permit(:username, :email, :password)
  end

  def verify_twilio_account
    if params[:AccountSid] != AppContainer.twilio_account_sid
      head 403
    end
  end
end
