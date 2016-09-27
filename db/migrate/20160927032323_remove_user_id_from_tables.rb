class RemoveUserIdFromTables < ActiveRecord::Migration[5.0]
  def change
    remove_column :tables, :user_id, :integer
  end
end
