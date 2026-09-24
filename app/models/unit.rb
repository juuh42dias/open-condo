class Unit < ApplicationRecord
  UNIT_TYPES = %w[apartment house studio loft penthouse].freeze
  STATUSES = %w[available occupied maintenance].freeze

  belongs_to :building
  has_many :residents, dependent: :destroy
  has_many :maintenance_requests, dependent: :destroy
  has_many :ownerships, dependent: :destroy
  has_many :owners, through: :ownerships
  has_many :payments, dependent: :destroy
  has_many :packages, dependent: :destroy
  has_many :violations, dependent: :destroy

  validates :unit_number, presence: true, uniqueness: { scope: :building_id }
  validates :unit_type, presence: true, inclusion: { in: UNIT_TYPES }
  validates :bedrooms, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :bathrooms, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :area, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :ordered, -> { order(:unit_number) }
  scope :occupied, -> { where(status: "occupied") }
  scope :available, -> { where(status: "available") }

  def current_resident
    residents.where(move_out_date: nil).first
  end

  def occupied?
    status == "occupied" || current_resident.present?
  end

  def label
    "#{building&.name} · Unit #{unit_number}"
  end

  def unit_type_label
    unit_type.to_s.titleize
  end

  def details
    "#{bedrooms} bd · #{bathrooms} ba · #{area} m²"
  end
end
