class CreateTables < ActiveRecord::Migration[5.0]
  def change
    create_table :tables do |t|
      t.integer :user_id
      t.integer :blind_amount
      t.string :common_cards
      t.boolean :started

      t.timestamps
    end
  end
end
