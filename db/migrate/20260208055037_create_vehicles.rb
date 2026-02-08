class CreateVehicles < ActiveRecord::Migration[8.1]
  def change
    create_table :vehicles do |t|
      t.string :name, null: false
      t.integer :vehicle_type, null: false, default: 0
      t.string :make, null: false
      t.string :model, null: false
      t.integer :year, null: false
      t.string :trim
      t.string :color
      t.string :vin
      t.string :license_plate
      t.integer :current_mileage
      t.text :notes

      t.timestamps
    end

    add_index :vehicles, :vehicle_type
    add_index :vehicles, :vin, unique: true, where: "vin IS NOT NULL"

    add_check_constraint :vehicles, "year >= 1900 AND year <= 2100", name: "vehicles_year_range"
    add_check_constraint :vehicles, "current_mileage >= 0", name: "vehicles_mileage_non_negative"
  end
end
