class ServiceRecord < ApplicationRecord
  belongs_to :vehicle

  enum :service_type, {
    oil_change: 0,
    tire_rotation: 1,
    tire_replacement: 2,
    brake_service: 3,
    battery: 4,
    fluid_flush: 5,
    filter_replacement: 6,
    inspection: 7,
    alignment: 8,
    other: 9
  }, validate: true

  validates :description, presence: true
  validates :performed_on, presence: true
  validates :mileage_at_service, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :cost_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :recent, -> { order(performed_on: :desc) }

  def cost_dollars
    cost_cents / 100.0 if cost_cents
  end

  def to_s
    "#{service_type.humanize} — #{performed_on}"
  end
end
