class ChangeMedia < ActiveRecord::Migration
  def change
    rename_column :media, :user_id, :poster_id
    add_column :media, :user_id, :integer, :null => false
  end
end
