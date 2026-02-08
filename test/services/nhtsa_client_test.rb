require "test_helper"

class NhtsaClientTest < ActiveSupport::TestCase
  NHTSA_BASE = "https://vpic.nhtsa.dot.gov/api/vehicles"

  test "decode_vin_values returns parsed JSON" do
    vin = "1HGBH41JXMN109186"
    body = { "Results" => [ { "Make" => "HONDA" } ] }.to_json
    stub_request(:get, "#{NHTSA_BASE}/DecodeVinValues/#{vin}?format=json")
      .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

    data = NhtsaClient.decode_vin_values(vin)

    assert_equal "HONDA", data.dig("Results", 0, "Make")
  end

  test "makes_for_vehicle_type returns sorted normalized make names" do
    body = { "Results" => [
      { "MakeName" => "HONDA" },
      { "MakeName" => "BMW" },
      { "MakeName" => "ACURA" },
      { "MakeName" => "GMC" }
    ] }.to_json
    stub_request(:get, "#{NHTSA_BASE}/GetMakesForVehicleType/car?format=json")
      .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

    makes = NhtsaClient.makes_for_vehicle_type("car")

    assert_equal %w[Acura BMW GMC Honda], makes
  end

  test "makes_for_vehicle_type returns empty array for unknown type" do
    assert_equal [], NhtsaClient.makes_for_vehicle_type("spaceship")
  end

  test "makes_for_vehicle_type returns empty array for nil type" do
    assert_equal [], NhtsaClient.makes_for_vehicle_type(nil)
  end

  test "models_for_make_year returns sorted model names" do
    body = { "Results" => [
      { "Model_Name" => "Civic" },
      { "Model_Name" => "Accord" },
      { "Model_Name" => "CR-V" }
    ] }.to_json
    stub_request(:get, "#{NHTSA_BASE}/GetModelsForMakeYear/make/Honda/modelyear/2022?format=json")
      .to_return(status: 200, body: body, headers: { "Content-Type" => "application/json" })

    models = NhtsaClient.models_for_make_year("Honda", "2022")

    assert_equal %w[Accord CR-V Civic], models
  end

  test "models_for_make_year returns empty array for blank make" do
    assert_equal [], NhtsaClient.models_for_make_year("", "2022")
  end

  test "models_for_make_year returns empty array for blank year" do
    assert_equal [], NhtsaClient.models_for_make_year("Honda", "")
  end

  test "raises RequestError on timeout" do
    stub_request(:get, "#{NHTSA_BASE}/DecodeVinValues/ABC?format=json").to_timeout

    error = assert_raises(NhtsaClient::RequestError) do
      NhtsaClient.decode_vin_values("ABC")
    end
    assert_match(/timed out/, error.message)
  end

  test "raises RequestError on HTTP 500" do
    stub_request(:get, "#{NHTSA_BASE}/DecodeVinValues/ABC?format=json")
      .to_return(status: 500, body: "")

    error = assert_raises(NhtsaClient::RequestError) do
      NhtsaClient.decode_vin_values("ABC")
    end
    assert_match(/HTTP 500/, error.message)
  end

  test "normalize_make titleizes regular names" do
    assert_equal "Chevrolet", NhtsaClient.normalize_make("CHEVROLET")
    assert_equal "Honda", NhtsaClient.normalize_make("HONDA")
  end

  test "normalize_make preserves BMW" do
    assert_equal "BMW", NhtsaClient.normalize_make("BMW")
    assert_equal "BMW", NhtsaClient.normalize_make("bmw")
  end

  test "normalize_make preserves GMC" do
    assert_equal "GMC", NhtsaClient.normalize_make("GMC")
    assert_equal "GMC", NhtsaClient.normalize_make("gmc")
  end
end
