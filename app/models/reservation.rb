class Reservation < ApplicationRecord
  STATUSES = %w[pending confirmed cancelled completed].freeze

  belongs_to :user
  belongs_to :common_area

  delegate :building, to: :common_area

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  validate :end_time_after_start_time
  validate :no_overlapping_reservations
  validate :reservation_within_future
  validate :calculate_total_cost

  scope :ordered, -> { order(start_time: :desc) }
  scope :upcoming, -> { where("start_time >= ?", Time.current).order(:start_time) }
  scope :past, -> { where("start_time < ?", Time.current) }
  scope :active, -> { where(status: %w[pending confirmed]) }
  scope :for_user, ->(user) { where(user: user) }

  def pending?
    status == "pending"
  end

  def confirmed?
    status == "confirmed"
  end

  def cancelled?
    status == "cancelled"
  end

  def upcoming?
    start_time.present? && start_time >= Time.current
  end

  def duration_hours
    return 0 unless start_time && end_time

    ((end_time - start_time) / 1.hour).round(1)
  end

  def confirm!
    update!(status: "confirmed")
  end

  def cancel!
    update!(status: "cancelled")
  end

  def time_range_label
    return "—" unless start_time && end_time

    "#{start_time.strftime('%b %-d, %Y %H:%M')} - #{end_time.strftime('%H:%M')}"
  end

  private

  def end_time_after_start_time
    return unless start_time && end_time

    errors.add(:end_time, "must be after start time") if end_time <= start_time
  end

  def no_overlapping_reservations
    return unless start_time && end_time && common_area

    overlapping = common_area.reservations.where.not(id: id)
      .where(status: %w[confirmed pending])
      .where("(start_time < ? AND end_time > ?)", end_time, start_time)

    errors.add(:base, "This time slot is already booked") if overlapping.exists?
  end

  def reservation_within_future
    return unless start_time
    return if persisted? && !start_time_changed?

    errors.add(:start_time, "must be in the future") if start_time < Time.current
  end

  def calculate_total_cost
    return unless start_time && end_time && common_area

    self.total_cost = (duration_hours * common_area.hourly_rate).round(2)
  end
end
