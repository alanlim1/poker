class AddCardsColumnToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :cards, :string
  end
end
