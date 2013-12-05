class CreateMedia < ActiveRecord::Migration
  def change
    create_table :media do |t|
      t.integer :user_id, :null => false
      t.string :file, :null => false

      t.timestamps
    end
  end
end
