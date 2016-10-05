class AddAccountToPlayer < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :account, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end
