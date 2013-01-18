class CreateWords < ActiveRecord::Migration
  def change
    create_table :words do |t|
      t.string :noun
      t.string :article
      t.integer :weight

      t.timestamps
    end
  end
end
