require "application_system_test_case"

class VinDecodeTest < ApplicationSystemTestCase
  test "decoding a VIN fills in vehicle fields" do
    vin = "1HGCV1F34LA000001"
    body = { "Results" => [ { "Make" => "HONDA", "Model" => "Accord", "ModelYear" => "2020", "Trim" => "Sport", "VehicleType" => "PASSENGER CAR" } ] }.to_json
    stub_request(:get, "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/#{vin}?format=json")
      .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

    # Stub makes/models fetches triggered by VIN decode filling fields
    stub_request(:get, %r{vpic\.nhtsa\.dot\.gov/api/vehicles/GetMakesForVehicleType})
      .to_return(status: 200, body: { "Results" => [] }.to_json, headers: { "Content-Type" => "application/json" })
    stub_request(:get, %r{vpic\.nhtsa\.dot\.gov/api/vehicles/GetModelsForMakeYear})
      .to_return(status: 200, body: { "Results" => [] }.to_json, headers: { "Content-Type" => "application/json" })

    visit new_vehicle_url

    fill_in "VIN", with: vin
    click_button "Decode VIN"

    assert_select "Make", selected: "Honda"
    assert_select "Model", selected: "Accord"
    assert_select "Year", selected: "2020"
    assert_field "Trim", with: "Sport"
    assert_select "Vehicle type", selected: "Car"
  end

  test "selecting vehicle type populates make dropdown" do
    makes_body = { "Results" => [
      { "MakeName" => "HONDA" },
      { "MakeName" => "TOYOTA" },
      { "MakeName" => "BMW" }
    ] }.to_json
    stub_request(:get, %r{vpic\.nhtsa\.dot\.gov/api/vehicles/GetMakesForVehicleType/car})
      .to_return(status: 200, body: makes_body, headers: { "Content-Type" => "application/json" })

    visit new_vehicle_url

    select "Car", from: "Vehicle type"

    assert_select_options("Make", %w[BMW Honda Toyota])
  end

  test "selecting make and year populates model dropdown" do
    stub_request(:get, %r{vpic\.nhtsa\.dot\.gov/api/vehicles/GetMakesForVehicleType/car})
      .to_return(status: 200, body: { "Results" => [ { "MakeName" => "HONDA" } ] }.to_json, headers: { "Content-Type" => "application/json" })

    models_body = { "Results" => [
      { "Model_Name" => "Civic" },
      { "Model_Name" => "Accord" },
      { "Model_Name" => "CR-V" }
    ] }.to_json
    stub_request(:get, %r{vpic\.nhtsa\.dot\.gov/api/vehicles/GetModelsForMakeYear/make/Honda/modelyear/2022})
      .to_return(status: 200, body: models_body, headers: { "Content-Type" => "application/json" })

    visit new_vehicle_url

    select "Car", from: "Vehicle type"
    assert_select_options("Make", %w[Honda])

    select "Honda", from: "Make"
    select "2022", from: "Year"

    assert_select_options("Model", %w[Accord CR-V Civic])
  end

  private

  def assert_select_options(label, expected_values)
    field = find_field(label)
    values = []
    # Retry to allow async fetch to complete
    10.times do
      values = field.all("option").map(&:value).reject(&:empty?)
      break if values.sort == expected_values.sort
      sleep 0.2
    end
    assert_equal expected_values.sort, values.sort,
      "Expected #{label} select to contain #{expected_values.inspect} but got #{values.inspect}"
  end
end
