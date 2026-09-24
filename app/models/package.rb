class Package < ApplicationRecord
  STATUSES = %w[received notified picked_up returned].freeze

  belongs_to :unit
  has_one :building, through: :unit

  validates :recipient_name, presence: true, length: { minimum: 2 }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :tracking_code, uniqueness: true, allow_blank: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :awaiting_pickup, -> { where(status: %w[received notified]) }
  scope :for_units, ->(unit_ids) { where(unit_id: unit_ids) }

  before_create :stamp_received_at

  def awaiting_pickup?
    %w[received notified].include?(status)
  end

  def picked_up?
    status == "picked_up"
  end

  def notify!
    update!(status: "notified", notified_at: Time.current)
  end

  def mark_picked_up!
    update!(status: "picked_up", picked_up_at: Time.current)
  end

  def mark_returned!
    update!(status: "returned")
  end

  def status_label
    status.to_s.tr("_", " ").titleize
  end

  private

  def stamp_received_at
    self.received_at ||= Time.current
  end
end
