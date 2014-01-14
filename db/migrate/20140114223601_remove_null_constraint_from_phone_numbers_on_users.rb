class RemoveNullConstraintFromPhoneNumbersOnUsers < ActiveRecord::Migration
  def change
    rename_column :users, :phone, :phone_number
    change_column :users, :phone_number, :string, :null => true
  end
end
