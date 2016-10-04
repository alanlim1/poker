class AddHoleColumnToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :hole, :string
  end
end
