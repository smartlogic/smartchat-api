class AddSmsVerificationCodeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sms_verification_code, :string
  end
end
