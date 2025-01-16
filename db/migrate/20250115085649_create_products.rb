class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.timestamps
      t.index :code, unique: true
    end
  end
end
