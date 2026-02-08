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

    assert_field "Make", with: "Honda"
    assert_field "Model", with: "Accord"
    assert_select "Year", selected: "2020"
    assert_field "Trim", with: "Sport"
    assert_select "Vehicle type", selected: "Car"
  end

  test "selecting vehicle type populates make suggestions" do
    makes_body = { "Results" => [
      { "MakeName" => "HONDA" },
      { "MakeName" => "TOYOTA" },
      { "MakeName" => "BMW" }
    ] }.to_json
    stub_request(:get, %r{vpic\.nhtsa\.dot\.gov/api/vehicles/GetMakesForVehicleType/car})
      .to_return(status: 200, body: makes_body, headers: { "Content-Type" => "application/json" })

    visit new_vehicle_url

    select "Car", from: "Vehicle type"

    # Wait for async fetch and verify datalist has options
    assert_datalist_options("make-options", %w[BMW Honda Toyota])
  end

  test "selecting make and year populates model suggestions" do
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
    select "2022", from: "Year"
    fill_in "Make", with: "Honda"
    # Trigger change event since fill_in doesn't fire it for datalist refresh
    find_field("Make").native.send_keys(:tab)

    assert_datalist_options("model-options", %w[Accord CR-V Civic])
  end

  private

  def assert_datalist_options(datalist_id, expected_values)
    values = []
    # Retry to allow async fetch to complete
    10.times do
      values = evaluate_script("Array.from(document.getElementById('#{datalist_id}').options).map(o => o.value)")
      break if values.sort == expected_values.sort
      sleep 0.2
    end
    assert_equal expected_values.sort, values.sort,
      "Expected datalist ##{datalist_id} to contain #{expected_values.inspect} but got #{values.inspect}"
  end
end
