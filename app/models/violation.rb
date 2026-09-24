class Violation < ApplicationRecord
  VIOLATION_TYPES = %w[noise parking pets common_area renovations safety trash other].freeze
  SEVERITIES = %w[low medium high critical].freeze
  STATUSES = %w[open acknowledged resolved dismissed fined].freeze

  belongs_to :unit
  belongs_to :reported_by, class_name: "User"
  has_one :building, through: :unit

  validates :title, presence: true, length: { minimum: 3 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :violation_type, presence: true, inclusion: { in: VIOLATION_TYPES }
  validates :severity, presence: true, inclusion: { in: SEVERITIES }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :fine_amount, numericality: { greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(created_at: :desc) }
  scope :open_cases, -> { where(status: %w[open acknowledged]) }
  scope :for_units, ->(unit_ids) { where(unit_id: unit_ids) }

  def open?
    %w[open acknowledged].include?(status)
  end

  def resolved?
    %w[resolved dismissed fined].include?(status)
  end

  def acknowledge!
    update!(status: "acknowledged")
  end

  def resolve!
    update!(status: "resolved", resolved_at: Time.current)
  end

  def dismiss!
    update!(status: "dismissed", resolved_at: Time.current)
  end

  # Convert the violation into a fine (Payment) billed to the unit.
  # Mirrors Condo Control / Buildium violation-to-fine workflows.
  def convert_to_fine!
    raise ActiveRecord::RecordInvalid, self unless fine_amount.to_d.positive?

    payer = unit.current_resident&.user || unit.owners.first&.user
    raise ActiveRecord::RecordInvalid, self, "Unit has no resident or owner to fine" if payer.nil?

    Payment.transaction do
      payment = Payment.create!(
        user: payer,
        unit: unit,
        amount: fine_amount,
        payment_type: "other",
        due_date: 15.days.from_now.to_date,
        status: "pending",
        description: "Violation fine: #{title}"
      )
      update!(status: "fined", resolved_at: Time.current)
      payment
    end
  end

  def status_label
    status.to_s.titleize
  end

  def severity_label
    severity.to_s.capitalize
  end

  def violation_type_label
    violation_type.to_s.tr("_", " ").titleize
  end
end
