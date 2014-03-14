class CreateSmarches < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
    create_table :smarches, :id => :uuid do |t|
      t.json :document
      t.timestamps
    end
  end
end
