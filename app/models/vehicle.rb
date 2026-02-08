class Vehicle < ApplicationRecord
  has_many :service_records, dependent: :destroy

  enum :vehicle_type, { car: 0, motorcycle: 1 }

  validates :name, presence: true
  validates :make, presence: true
  validates :model, presence: true
  validates :year, presence: true,
                   numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: 2100 }
  validates :vehicle_type, presence: true
  validates :vin, uniqueness: true, allow_blank: true
  validates :current_mileage, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def to_s
    "#{year} #{make} #{model}"
  end
end
