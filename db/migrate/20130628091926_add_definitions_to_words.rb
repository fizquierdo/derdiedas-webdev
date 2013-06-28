class AddDefinitionsToWords < ActiveRecord::Migration
  def change
    add_column :words, :definitions, :text
  end
end
