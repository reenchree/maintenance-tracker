require "net/http"

class NhtsaClient
  class RequestError < StandardError; end

  BASE_URL = "https://vpic.nhtsa.dot.gov/api/vehicles"
  TIMEOUT_SECONDS = 5

  # Short makes that should stay uppercase rather than being titleized
  UPPERCASE_MAKES = %w[BMW GMC].freeze

  # Maps app vehicle_type enum values to NHTSA vehicle type path segments
  VEHICLE_TYPE_PATHS = {
    "car" => "car",
    "motorcycle" => "motorcycle"
  }.freeze

  # Returns parsed JSON hash from NHTSA DecodeVinValues endpoint
  def self.decode_vin_values(vin)
    get("/DecodeVinValues/#{vin}?format=json")
  end

  # Returns sorted array of normalized make name strings
  def self.makes_for_vehicle_type(vehicle_type)
    path_segment = VEHICLE_TYPE_PATHS[vehicle_type.to_s]
    return [] if path_segment.nil?

    data = get("/GetMakesForVehicleType/#{path_segment}?format=json")
    makes = data.dig("Results") || []

    makes
      .filter_map { |entry| entry["MakeName"]&.strip.presence }
      .map { |name| normalize_make(name) }
      .uniq
      .sort
  end

  # Returns sorted array of model name strings
  def self.models_for_make_year(make, year)
    return [] if make.blank? || year.blank?

    encoded_make = ERB::Util.url_encode(make)
    data = get("/GetModelsForMakeYear/make/#{encoded_make}/modelyear/#{year}?format=json")
    models = data.dig("Results") || []

    models
      .filter_map { |entry| entry["Model_Name"]&.strip.presence }
      .uniq
      .sort
  end

  def self.normalize_make(name)
    upcased = name.strip.upcase
    return upcased if UPPERCASE_MAKES.include?(upcased)

    name.strip.titleize
  end

  def self.get(path)
    uri = URI("#{BASE_URL}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = TIMEOUT_SECONDS
    http.read_timeout = TIMEOUT_SECONDS

    response = http.get(uri.request_uri)
    raise RequestError, "NHTSA returned HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  rescue Net::OpenTimeout, Net::ReadTimeout
    raise RequestError, "request timed out"
  end

  private_class_method :get
end
