class CreateServiceRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :service_records do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.integer :service_type, null: false, default: 0
      t.string :description, null: false
      t.date :performed_on, null: false
      t.integer :mileage_at_service
      t.integer :cost_cents
      t.string :shop_or_mechanic
      t.text :notes

      t.timestamps
    end

    add_index :service_records, :service_type
    add_index :service_records, :performed_on

    add_check_constraint :service_records, "mileage_at_service >= 0", name: "service_records_mileage_non_negative"
    add_check_constraint :service_records, "cost_cents >= 0", name: "service_records_cost_non_negative"
  end
end
