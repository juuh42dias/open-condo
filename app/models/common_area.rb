class CommonArea < ApplicationRecord
  belongs_to :building
  has_many :reservations, dependent: :destroy

  validates :name, presence: true, length: { minimum: 2 }
  validates :description, presence: true
  validates :capacity, presence: true, numericality: { greater_than: 0 }
  validates :hourly_rate, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:name) }

  def free?
    hourly_rate.to_d.zero?
  end

  def rate_label
    free? ? "Free" : "#{ActiveSupport::NumberHelper.number_to_currency(hourly_rate)}/hour"
  end
end
