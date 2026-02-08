require "test_helper"

class VinDecoderTest < ActiveSupport::TestCase
  SAMPLE_VIN = "1HGBH41JXMN109186"
  NHTSA_URL = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/#{SAMPLE_VIN}?format=json"

  test "decodes a valid VIN with all fields" do
    stub_nhtsa(Make: "HONDA", Model: "Civic", ModelYear: "2022", Trim: "EX-L", VehicleType: "PASSENGER CAR")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_nil result.error
    assert_equal "Honda", result.make
    assert_equal "Civic", result.model
    assert_equal 2022, result.year
    assert_equal "EX-L", result.trim
    assert_equal "car", result.vehicle_type
  end

  test "maps motorcycle vehicle type" do
    stub_nhtsa(Make: "HARLEY-DAVIDSON", Model: "Sportster S", ModelYear: "2024", Trim: "", VehicleType: "MOTORCYCLE")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_nil result.error
    assert_equal "Harley Davidson", result.make
    assert_equal "motorcycle", result.vehicle_type
  end

  test "maps MPV vehicle type to car" do
    stub_nhtsa(Make: "TOYOTA", Model: "Highlander", ModelYear: "2023", Trim: "XLE", VehicleType: "MULTIPURPOSE PASSENGER VEHICLE (MPV)")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_equal "car", result.vehicle_type
  end

  test "maps truck vehicle type to car" do
    stub_nhtsa(Make: "FORD", Model: "F-150", ModelYear: "2023", Trim: "XLT", VehicleType: "TRUCK")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_equal "car", result.vehicle_type
  end

  test "handles partial data with no trim" do
    stub_nhtsa(Make: "HONDA", Model: "Civic", ModelYear: "2022", Trim: "", VehicleType: "PASSENGER CAR")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_nil result.error
    assert_equal "Honda", result.make
    assert_nil result.trim
  end

  test "returns error for blank VIN" do
    result = VinDecoder.decode("")

    assert_equal "VIN is required", result.error
    assert_nil result.make
  end

  test "returns error for wrong-length VIN" do
    result = VinDecoder.decode("ABC123")

    assert_equal "VIN must be 17 characters", result.error
    assert_nil result.make
  end

  test "returns error when VIN cannot be decoded" do
    stub_nhtsa(Make: "", Model: "", ModelYear: "", Trim: "", VehicleType: "")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_equal "Could not decode this VIN", result.error
  end

  test "returns error on timeout" do
    stub_request(:get, NHTSA_URL).to_timeout

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_match(/timed out/, result.error)
  end

  test "returns error on HTTP 500" do
    stub_request(:get, NHTSA_URL).to_return(status: 500, body: "")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_match(/HTTP 500/, result.error)
  end

  test "preserves short acronym makes like BMW" do
    stub_nhtsa(Make: "BMW", Model: "330i", ModelYear: "2023", Trim: "xDrive", VehicleType: "PASSENGER CAR")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_equal "BMW", result.make
  end

  test "preserves short acronym makes like GMC" do
    stub_nhtsa(Make: "GMC", Model: "Sierra 1500", ModelYear: "2023", Trim: "SLE", VehicleType: "TRUCK")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_equal "GMC", result.make
  end

  test "titleizes regular makes from all caps" do
    stub_nhtsa(Make: "CHEVROLET", Model: "Malibu", ModelYear: "2023", Trim: "LT", VehicleType: "PASSENGER CAR")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_equal "Chevrolet", result.make
  end

  test "maps unknown vehicle type to car" do
    stub_nhtsa(Make: "TESLA", Model: "Model 3", ModelYear: "2023", Trim: "", VehicleType: "LOW SPEED VEHICLE (LSV)")

    result = VinDecoder.decode(SAMPLE_VIN)

    assert_equal "car", result.vehicle_type
  end

  private

  def stub_nhtsa(make: "", model: "", model_year: "", trim: "", vehicle_type: "", **overrides)
    # Allow keyword or hash-style arguments
    fields = {
      "Make" => overrides[:Make] || make,
      "Model" => overrides[:Model] || model,
      "ModelYear" => overrides[:ModelYear] || model_year,
      "Trim" => overrides[:Trim] || trim,
      "VehicleType" => overrides[:VehicleType] || vehicle_type
    }

    body = { "Results" => [ fields ] }.to_json
    stub_request(:get, NHTSA_URL).to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })
  end
end
