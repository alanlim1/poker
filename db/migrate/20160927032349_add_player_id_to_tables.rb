class AddPlayerIdToTables < ActiveRecord::Migration[5.0]
  def change
    add_column :tables, :player_id, :integer
  end
end
