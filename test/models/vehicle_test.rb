require "test_helper"

class VehicleTest < ActiveSupport::TestCase
  test "valid vehicle" do
    vehicle = Vehicle.new(name: "Test Car", vehicle_type: :car, make: "Toyota", model: "Camry", year: 2023)
    assert vehicle.valid?
  end

  test "requires name" do
    vehicle = Vehicle.new(make: "Toyota", model: "Camry", year: 2023, vehicle_type: :car)
    assert_not vehicle.valid?
    assert_includes vehicle.errors[:name], "can't be blank"
  end

  test "requires make" do
    vehicle = Vehicle.new(name: "Test", model: "Camry", year: 2023, vehicle_type: :car)
    assert_not vehicle.valid?
    assert_includes vehicle.errors[:make], "can't be blank"
  end

  test "requires model" do
    vehicle = Vehicle.new(name: "Test", make: "Toyota", year: 2023, vehicle_type: :car)
    assert_not vehicle.valid?
    assert_includes vehicle.errors[:model], "can't be blank"
  end

  test "requires year" do
    vehicle = Vehicle.new(name: "Test", make: "Toyota", model: "Camry", vehicle_type: :car)
    assert_not vehicle.valid?
    assert_includes vehicle.errors[:year], "can't be blank"
  end

  test "year must be in valid range" do
    vehicle = Vehicle.new(name: "Test", make: "Toyota", model: "Camry", year: 1800, vehicle_type: :car)
    assert_not vehicle.valid?
    assert_includes vehicle.errors[:year], "must be greater than or equal to 1900"
  end

  test "mileage cannot be negative" do
    vehicle = Vehicle.new(name: "Test", make: "Toyota", model: "Camry", year: 2023, vehicle_type: :car, current_mileage: -1)
    assert_not vehicle.valid?
    assert_includes vehicle.errors[:current_mileage], "must be greater than or equal to 0"
  end

  test "mileage can be nil" do
    vehicle = Vehicle.new(name: "Test", make: "Toyota", model: "Camry", year: 2023, vehicle_type: :car, current_mileage: nil)
    assert vehicle.valid?
  end

  test "vin uniqueness" do
    Vehicle.create!(name: "Car 1", make: "Honda", model: "Civic", year: 2022, vehicle_type: :car, vin: "ABC123")
    duplicate = Vehicle.new(name: "Car 2", make: "Honda", model: "Accord", year: 2023, vehicle_type: :car, vin: "ABC123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:vin], "has already been taken"
  end

  test "blank vin is allowed" do
    vehicle = Vehicle.new(name: "Test", make: "Toyota", model: "Camry", year: 2023, vehicle_type: :car, vin: "")
    assert vehicle.valid?
  end

  test "vehicle_type enum" do
    car = Vehicle.new(vehicle_type: :car)
    assert car.car?

    motorcycle = Vehicle.new(vehicle_type: :motorcycle)
    assert motorcycle.motorcycle?
  end

  test "to_s returns year make model" do
    vehicle = Vehicle.new(make: "Honda", model: "Civic", year: 2022)
    assert_equal "2022 Honda Civic", vehicle.to_s
  end

  test "destroying vehicle destroys service records" do
    vehicle = vehicles(:civic)
    assert vehicle.service_records.any?

    assert_difference("ServiceRecord.count", -vehicle.service_records.count) do
      vehicle.destroy
    end
  end
end
