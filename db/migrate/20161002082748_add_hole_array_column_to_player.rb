class AddHoleArrayColumnToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :holearray, :array
  end
end
