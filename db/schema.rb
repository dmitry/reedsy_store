# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_17_104124) do
  create_table "product_discounts", force: :cascade do |t|
    t.integer "product_id", null: false
    t.integer "min_quantity", null: false
    t.decimal "percentage", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "min_quantity"], name: "index_product_discounts_on_product_id_and_min_quantity", unique: true
    t.index ["product_id"], name: "index_product_discounts_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "code", limit: 20, null: false
    t.string "name", limit: 100, null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_products_on_code", unique: true
  end

  add_foreign_key "product_discounts", "products"
end
