class CreateGuesses < ActiveRecord::Migration
  def change
    create_table :guesses do |t|
      t.string :answer
      t.integer :word_id
      t.integer :user_id

      t.timestamps
    end
    add_index :guesses, [:user_id, :created_at, :word_id]
  end
end
