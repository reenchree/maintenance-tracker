require "test_helper"

class VehiclesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @vehicle = vehicles(:civic)
  end

  test "should get index" do
    get vehicles_url
    assert_response :success
  end

  test "should get new" do
    get new_vehicle_url
    assert_response :success
  end

  test "should create vehicle" do
    assert_difference("Vehicle.count") do
      post vehicles_url, params: { vehicle: { color: @vehicle.color, current_mileage: @vehicle.current_mileage, license_plate: @vehicle.license_plate, make: @vehicle.make, model: @vehicle.model, name: @vehicle.name, notes: @vehicle.notes, trim: @vehicle.trim, vehicle_type: @vehicle.vehicle_type, vin: "UNIQUE#{SecureRandom.hex(8)}", year: @vehicle.year } }
    end

    assert_redirected_to vehicle_url(Vehicle.last)
  end

  test "should show vehicle" do
    get vehicle_url(@vehicle)
    assert_response :success
  end

  test "should get edit" do
    get edit_vehicle_url(@vehicle)
    assert_response :success
  end

  test "should update vehicle" do
    patch vehicle_url(@vehicle), params: { vehicle: { color: @vehicle.color, current_mileage: @vehicle.current_mileage, license_plate: @vehicle.license_plate, make: @vehicle.make, model: @vehicle.model, name: @vehicle.name, notes: @vehicle.notes, trim: @vehicle.trim, vehicle_type: @vehicle.vehicle_type, vin: @vehicle.vin, year: @vehicle.year } }
    assert_redirected_to vehicle_url(@vehicle)
  end

  test "should destroy vehicle" do
    assert_difference("Vehicle.count", -1) do
      delete vehicle_url(@vehicle)
    end

    assert_redirected_to vehicles_url
  end

  test "decode_vin returns vehicle data for valid VIN" do
    vin = "1HGBH41JXMN109186"
    body = { "Results" => [ { "Make" => "HONDA", "Model" => "Civic", "ModelYear" => "2022", "Trim" => "EX-L", "VehicleType" => "PASSENGER CAR" } ] }.to_json
    stub_request(:get, "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/#{vin}?format=json")
      .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

    get decode_vin_vehicles_url, params: { vin: vin }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Honda", json["make"]
    assert_equal "Civic", json["model"]
    assert_equal 2022, json["year"]
    assert_equal "EX-L", json["trim"]
    assert_equal "car", json["vehicle_type"]
    assert_nil json["error"]
  end

  test "makes returns JSON array of make names" do
    body = { "Results" => [ { "MakeName" => "HONDA" }, { "MakeName" => "TOYOTA" } ] }.to_json
    stub_request(:get, "https://vpic.nhtsa.dot.gov/api/vehicles/GetMakesForVehicleType/car?format=json")
      .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

    get makes_vehicles_url, params: { vehicle_type: "car" }

    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_includes json, "Honda"
    assert_includes json, "Toyota"
  end

  test "makes returns empty array when vehicle_type is missing" do
    get makes_vehicles_url

    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "models returns JSON array of model names" do
    body = { "Results" => [ { "Model_Name" => "Civic" }, { "Model_Name" => "Accord" } ] }.to_json
    stub_request(:get, "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMakeYear/make/Honda/modelyear/2022?format=json")
      .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

    get models_vehicles_url, params: { make: "Honda", year: "2022" }

    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
    assert_includes json, "Civic"
    assert_includes json, "Accord"
  end

  test "models returns empty array when params are missing" do
    get models_vehicles_url

    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end

  test "decode_vin returns error for invalid VIN" do
    get decode_vin_vehicles_url, params: { vin: "SHORT" }

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "VIN must be 17 characters", json["error"]
    assert_nil json["make"]
  end
end
