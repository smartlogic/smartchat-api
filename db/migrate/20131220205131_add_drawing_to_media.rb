class AddDrawingToMedia < ActiveRecord::Migration
  def change
    add_column :media, :drawing, :string
  end
end
