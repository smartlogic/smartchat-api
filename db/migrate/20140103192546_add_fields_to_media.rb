class AddFieldsToMedia < ActiveRecord::Migration
  def change
    add_column :media, :published, :boolean, :null => false, :default => false
    add_column :media, :encrypted_aes_key, :text
    add_column :media, :encrypted_aes_iv, :text
  end
end
