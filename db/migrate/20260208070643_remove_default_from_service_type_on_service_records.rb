class RemoveDefaultFromServiceTypeOnServiceRecords < ActiveRecord::Migration[8.1]
  def change
    change_column_default :service_records, :service_type, from: 0, to: nil
  end
end
