class VinDecoder
  Result = Data.define(:make, :model, :year, :trim, :vehicle_type, :error)

  VEHICLE_TYPE_MAP = {
    "PASSENGER CAR" => "car",
    "MULTIPURPOSE PASSENGER VEHICLE (MPV)" => "car",
    "TRUCK" => "car",
    "MOTORCYCLE" => "motorcycle"
  }.freeze

  def self.decode(vin)
    new(vin).decode
  end

  def initialize(vin)
    @vin = vin.to_s.strip
  end

  def decode
    return error_result("VIN is required") if @vin.blank?
    return error_result("VIN must be 17 characters") if @vin.length != 17

    data = NhtsaClient.decode_vin_values(@vin)
    parse_response(data)
  rescue NhtsaClient::RequestError => e
    if e.message.match?(/timeout/i)
      error_result("VIN lookup timed out — please try again")
    else
      error_result("VIN lookup failed: #{e.message}")
    end
  rescue StandardError => e
    error_result("VIN lookup failed: #{e.message}")
  end

  private

  def parse_response(data)
    result = data.dig("Results", 0)
    return error_result("No results returned from NHTSA") if result.nil?

    make = presence(result["Make"])
    return error_result("Could not decode this VIN") if make.nil?

    Result.new(
      make: NhtsaClient.normalize_make(make),
      model: presence(result["Model"])&.strip,
      year: presence(result["ModelYear"])&.to_i,
      trim: presence(result["Trim"])&.strip,
      vehicle_type: map_vehicle_type(presence(result["VehicleType"])),
      error: nil
    )
  end

  def map_vehicle_type(vehicle_type)
    return nil if vehicle_type.nil?

    VEHICLE_TYPE_MAP.fetch(vehicle_type.upcase, "car")
  end

  def presence(value)
    value.present? ? value : nil
  end

  def error_result(message)
    Result.new(make: nil, model: nil, year: nil, trim: nil, vehicle_type: nil, error: message)
  end
end
