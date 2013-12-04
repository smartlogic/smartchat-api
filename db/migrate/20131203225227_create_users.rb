class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, :null => false
      t.string :password_hash, :null => false
      t.string :phone, :null => false
      t.text :private_key, :null => false
      t.text :public_key, :null => false

      t.timestamps
    end
  end
end
