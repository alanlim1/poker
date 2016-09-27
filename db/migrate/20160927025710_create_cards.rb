class CreateCards < ActiveRecord::Migration[5.0]
  def change
    create_table :cards do |t|
      t.string :suit
      t.string :face
      t.string :image

      t.timestamps
    end
  end
end
