class CreateFriends < ActiveRecord::Migration
  def change
    create_table :friends do |t|
      t.integer :from_id, :null => false
      t.integer :to_id, :null => false
    end

    add_index :friends, [:from_id, :to_id], :unique => true
  end
end
