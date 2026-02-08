require "application_system_test_case"

class VinDecodeTest < ApplicationSystemTestCase
  test "decoding a VIN fills in vehicle fields" do
    vin = "1HGCV1F34LA000001"
    body = { "Results" => [ { "Make" => "HONDA", "Model" => "Accord", "ModelYear" => "2020", "Trim" => "Sport", "VehicleType" => "PASSENGER CAR" } ] }.to_json
    stub_request(:get, "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues/#{vin}?format=json")
      .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

    visit new_vehicle_url

    fill_in "VIN", with: vin
    click_button "Decode VIN"

    assert_field "Make", with: "Honda"
    assert_field "Model", with: "Accord"
    assert_field "Year", with: "2020"
    assert_field "Trim", with: "Sport"
    assert_select "Vehicle type", selected: "Car"
  end
end
