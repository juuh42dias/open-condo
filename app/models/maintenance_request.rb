class MaintenanceRequest < ApplicationRecord
  CATEGORIES = %w[plumbing electrical hvac appliance structural cleaning elevator pest_control other].freeze
  PRIORITIES = %w[low medium high urgent].freeze
  STATUSES = %w[pending in_progress completed cancelled].freeze

  belongs_to :user
  belongs_to :unit

  delegate :building, to: :unit

  validates :title, presence: true, length: { minimum: 3 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :priority, presence: true, inclusion: { in: PRIORITIES }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true

  scope :ordered, -> { order(created_at: :desc) }
  scope :open_requests, -> { where(status: %w[pending in_progress]) }
  scope :pending, -> { where(status: "pending") }
  scope :in_progress, -> { where(status: "in_progress") }
  scope :completed, -> { where(status: "completed") }
  scope :by_priority, -> { order(Arel.sql("CASE priority WHEN 'urgent' THEN 1 WHEN 'high' THEN 2 WHEN 'medium' THEN 3 WHEN 'low' THEN 4 END")) }
  scope :for_user, ->(user) { where(user: user) }

  def completed?
    status == "completed"
  end

  def pending?
    status == "pending"
  end

  def in_progress?
    status == "in_progress"
  end

  def cancelled?
    status == "cancelled"
  end

  def open?
    pending? || in_progress?
  end

  def mark_in_progress!
    update!(status: "in_progress")
  end

  def mark_completed!
    update!(status: "completed", completed_at: Time.current)
  end

  def cancel!
    update!(status: "cancelled")
  end

  def category_label
    category.presence&.titleize || "General"
  end

  def status_label
    status.to_s.tr("_", " ").titleize
  end
end
