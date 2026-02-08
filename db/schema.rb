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

ActiveRecord::Schema[8.1].define(version: 2026_02_08_070643) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "service_records", force: :cascade do |t|
    t.integer "cost_cents"
    t.datetime "created_at", null: false
    t.string "description", null: false
    t.integer "mileage_at_service"
    t.text "notes"
    t.date "performed_on", null: false
    t.integer "service_type", null: false
    t.string "shop_or_mechanic"
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id", null: false
    t.index ["performed_on"], name: "index_service_records_on_performed_on"
    t.index ["service_type"], name: "index_service_records_on_service_type"
    t.index ["vehicle_id"], name: "index_service_records_on_vehicle_id"
    t.check_constraint "cost_cents >= 0", name: "service_records_cost_non_negative"
    t.check_constraint "mileage_at_service >= 0", name: "service_records_mileage_non_negative"
  end

  create_table "vehicles", force: :cascade do |t|
    t.string "color"
    t.datetime "created_at", null: false
    t.integer "current_mileage"
    t.string "license_plate"
    t.string "make", null: false
    t.string "model", null: false
    t.string "name", null: false
    t.text "notes"
    t.string "trim"
    t.datetime "updated_at", null: false
    t.integer "vehicle_type", default: 0, null: false
    t.string "vin"
    t.integer "year", null: false
    t.index ["vehicle_type"], name: "index_vehicles_on_vehicle_type"
    t.index ["vin"], name: "index_vehicles_on_vin", unique: true, where: "(vin IS NOT NULL)"
    t.check_constraint "current_mileage >= 0", name: "vehicles_mileage_non_negative"
    t.check_constraint "year >= 1900 AND year <= 2100", name: "vehicles_year_range"
  end

  add_foreign_key "service_records", "vehicles"
end
