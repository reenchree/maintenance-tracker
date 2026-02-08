json.extract! vehicle, :id, :name, :vehicle_type, :make, :model, :year, :trim, :color, :vin, :license_plate, :current_mileage, :notes, :created_at, :updated_at
json.url vehicle_url(vehicle, format: :json)
