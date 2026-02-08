require "test_helper"

class ServiceRecordTest < ActiveSupport::TestCase
  test "valid service record" do
    record = ServiceRecord.new(
      vehicle: vehicles(:civic),
      service_type: :oil_change,
      description: "Oil change",
      performed_on: Date.current
    )
    assert record.valid?
  end

  test "belongs to vehicle" do
    record = service_records(:oil_change)
    assert_equal vehicles(:civic), record.vehicle
  end

  test "requires description" do
    record = ServiceRecord.new(vehicle: vehicles(:civic), service_type: :oil_change, performed_on: Date.current)
    assert_not record.valid?
    assert_includes record.errors[:description], "can't be blank"
  end

  test "requires performed_on" do
    record = ServiceRecord.new(vehicle: vehicles(:civic), service_type: :oil_change, description: "Oil change")
    assert_not record.valid?
    assert_includes record.errors[:performed_on], "can't be blank"
  end

  test "requires service_type" do
    record = ServiceRecord.new(vehicle: vehicles(:civic), description: "Oil change", performed_on: Date.current)
    record.service_type = nil
    assert_not record.valid?
    assert_includes record.errors[:service_type], "is not included in the list"
  end

  test "rejects invalid service_type" do
    record = ServiceRecord.new(
      vehicle: vehicles(:civic), description: "Oil change", performed_on: Date.current,
      service_type: "bogus"
    )
    assert_not record.valid?
    assert_includes record.errors[:service_type], "is not included in the list"
  end

  test "mileage must be integer" do
    record = ServiceRecord.new(
      vehicle: vehicles(:civic), service_type: :oil_change,
      description: "Oil change", performed_on: Date.current,
      mileage_at_service: 42000.5
    )
    assert_not record.valid?
    assert_includes record.errors[:mileage_at_service], "must be an integer"
  end

  test "mileage cannot be negative" do
    record = ServiceRecord.new(
      vehicle: vehicles(:civic), service_type: :oil_change,
      description: "Oil change", performed_on: Date.current,
      mileage_at_service: -1
    )
    assert_not record.valid?
    assert_includes record.errors[:mileage_at_service], "must be greater than or equal to 0"
  end

  test "mileage can be nil" do
    record = ServiceRecord.new(
      vehicle: vehicles(:civic), service_type: :oil_change,
      description: "Oil change", performed_on: Date.current,
      mileage_at_service: nil
    )
    assert record.valid?
  end

  test "cost_cents cannot be negative" do
    record = ServiceRecord.new(
      vehicle: vehicles(:civic), service_type: :oil_change,
      description: "Oil change", performed_on: Date.current,
      cost_cents: -1
    )
    assert_not record.valid?
    assert_includes record.errors[:cost_cents], "must be greater than or equal to 0"
  end

  test "cost_cents can be nil" do
    record = ServiceRecord.new(
      vehicle: vehicles(:civic), service_type: :oil_change,
      description: "Oil change", performed_on: Date.current,
      cost_cents: nil
    )
    assert record.valid?
  end

  test "service_type enum" do
    record = ServiceRecord.new(service_type: :oil_change)
    assert record.oil_change?

    record.service_type = :inspection
    assert record.inspection?
  end

  test "cost_dollars returns dollars from cents" do
    record = ServiceRecord.new(cost_cents: 7500)
    assert_equal 75.0, record.cost_dollars
  end

  test "cost_dollars returns nil when cost_cents is nil" do
    record = ServiceRecord.new(cost_cents: nil)
    assert_nil record.cost_dollars
  end

  test "to_s returns humanized type and date" do
    record = ServiceRecord.new(service_type: :oil_change, performed_on: Date.new(2025, 11, 15))
    assert_equal "Oil change — 2025-11-15", record.to_s
  end

  test "recent scope orders by performed_on desc" do
    records = vehicles(:civic).service_records.recent
    assert_equal service_records(:tire_rotation), records.first
    assert_equal service_records(:oil_change), records.last
  end
end
