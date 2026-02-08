require "net/http"

class VinDecoder
  Result = Data.define(:make, :model, :year, :trim, :vehicle_type, :error)

  NHTSA_BASE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles/DecodeVinValues"
  TIMEOUT_SECONDS = 5

  VEHICLE_TYPE_MAP = {
    "PASSENGER CAR" => "car",
    "MULTIPURPOSE PASSENGER VEHICLE (MPV)" => "car",
    "TRUCK" => "car",
    "MOTORCYCLE" => "motorcycle"
  }.freeze

  # Short makes that should stay uppercase rather than being titleized
  UPPERCASE_MAKES = %w[BMW GMC].freeze

  def self.decode(vin)
    new(vin).decode
  end

  def initialize(vin)
    @vin = vin.to_s.strip
  end

  def decode
    return error_result("VIN is required") if @vin.blank?
    return error_result("VIN must be 17 characters") if @vin.length != 17

    response = fetch_from_nhtsa
    parse_response(response)
  rescue Net::OpenTimeout, Net::ReadTimeout
    error_result("VIN lookup timed out — please try again")
  rescue StandardError => e
    error_result("VIN lookup failed: #{e.message}")
  end

  private

  def fetch_from_nhtsa
    uri = URI("#{NHTSA_BASE_URL}/#{@vin}?format=json")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = TIMEOUT_SECONDS
    http.read_timeout = TIMEOUT_SECONDS

    response = http.get(uri.request_uri)
    raise "NHTSA returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def parse_response(data)
    result = data.dig("Results", 0)
    return error_result("No results returned from NHTSA") if result.nil?

    make = presence(result["Make"])
    return error_result("Could not decode this VIN") if make.nil?

    Result.new(
      make: normalize_make(make),
      model: presence(result["Model"])&.strip,
      year: presence(result["ModelYear"])&.to_i,
      trim: presence(result["Trim"])&.strip,
      vehicle_type: map_vehicle_type(presence(result["VehicleType"])),
      error: nil
    )
  end

  def normalize_make(make)
    upcased = make.strip.upcase
    return upcased if UPPERCASE_MAKES.include?(upcased)

    make.strip.titleize
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
