class AddPlayerIdToCards < ActiveRecord::Migration[5.0]
  def change
    add_column :cards, :player_id, :integer
  end
end
