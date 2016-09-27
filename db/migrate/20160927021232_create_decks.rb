class CreateDecks < ActiveRecord::Migration[5.0]
  def change
    create_table :decks do |t|
      t.string :image
      t.string :face
      t.string :suit

      t.timestamps
    end
  end
end
