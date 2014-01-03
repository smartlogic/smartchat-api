class AddEncryptedAesForDrawingsToMedia < ActiveRecord::Migration
  def change
    add_column :media, :drawing_encrypted_aes_key, :text
    add_column :media, :drawing_encrypted_aes_iv, :text
  end
end
