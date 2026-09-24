class Building < ApplicationRecord
  has_many :units, dependent: :destroy
  has_many :common_areas, dependent: :destroy
  has_many :notices, dependent: :destroy
  has_many :polls, dependent: :destroy
  has_many :residents, through: :units
  has_many :owners, through: :units
  has_many :packages, through: :units
  has_many :violations, through: :units

  validates :name, presence: true, length: { minimum: 2 }
  validates :address, presence: true
  validates :total_units, presence: true, numericality: { greater_than: 0 }

  scope :ordered, -> { order(:name) }

  def occupied_units
    units.where(status: "occupied")
  end

  def available_units
    units.where(status: "available")
  end

  def occupancy_rate
    return 0 if units.count.zero?

    (occupied_units.count.to_f / units.count * 100).round
  end

  def unit_count
    units.count
  end
end
