class CreateProductDiscounts < ActiveRecord::Migration[8.0]
  def change
    create_table :product_discounts do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :min_quantity, null: false
      t.decimal :percentage, precision: 5, scale: 2, null: false
      t.timestamps
      t.index [ :product_id, :min_quantity ], unique: true
    end
  end
end
