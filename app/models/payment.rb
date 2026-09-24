class Payment < ApplicationRecord
  PAYMENT_TYPES = %w[condo_fee rent maintenance parking utilities other].freeze
  STATUSES = %w[pending paid overdue cancelled].freeze

  belongs_to :user
  belongs_to :unit

  delegate :building, to: :unit

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_type, presence: true, inclusion: { in: PAYMENT_TYPES }
  validates :due_date, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :description, presence: true, length: { minimum: 3 }

  scope :ordered, -> { order(due_date: :desc, created_at: :desc) }
  scope :paid, -> { where(status: "paid") }
  scope :pending, -> { where(status: "pending") }
  scope :overdue_scope, -> { where(status: "overdue") }
  scope :due_this_month, -> { where(due_date: Date.current.beginning_of_month..Date.current.end_of_month) }

  def paid?
    status == "paid"
  end

  def pending?
    status == "pending"
  end

  def overdue?
    status == "overdue" || (pending? && due_date.present? && due_date < Date.current)
  end

  def mark_as_paid!
    update!(status: "paid", paid_at: Time.current)
  end

  def mark_as_pending!
    update!(status: "pending", paid_at: nil)
  end

  def self.overdue
    where("due_date < ? AND status IN (?)", Date.current, %w[pending overdue])
  end

  # Automation inspired by Buildium / AppFolio: sweep past-due charges to overdue.
  def self.mark_overdue!
    where(status: "pending").where("due_date < ?", Date.current).update_all(status: "overdue")
  end

  # Generate one condo_fee charge per unit for the given month (idempotent).
  # Usage: Payment.generate_monthly_fees!(amount: 500, reference_date: Date.current)
  def self.generate_monthly_fees!(amount:, reference_date: Date.current, payment_type: "condo_fee")
    month_label = reference_date.strftime("%B %Y")
    due = reference_date.end_of_month
    created = 0

    Unit.find_each do |unit|
      description = "Monthly #{payment_type.tr('_', ' ')} - #{month_label}"
      next if exists?(unit_id: unit.id, payment_type: payment_type, description: description)

      payer = unit.current_resident&.user || unit.owners.first&.user || unit.payments.first&.user
      next if payer.nil?

      create!(
        user: payer,
        unit: unit,
        amount: amount,
        payment_type: payment_type,
        due_date: due,
        status: "pending",
        description: description
      )
      created += 1
    end

    created
  end

  # Create late-fee charges for overdue payments (idempotent per charge).
  def self.apply_late_fees!(percentage: 2.0)
    created = 0
    overdue.find_each do |payment|
      marker = "Late fee for charge ##{payment.id}"
      next if exists?(description: marker, unit_id: payment.unit_id)

      fee = (payment.amount * percentage / 100.0).round(2)
      next if fee <= 0

      create!(
        user: payment.user,
        unit: payment.unit,
        amount: fee,
        payment_type: "other",
        due_date: Date.current,
        status: "pending",
        description: marker
      )
      created += 1
    end
    created
  end

  # Summary hash used by dashboards and reports.
  def self.financial_summary(relation = all)
    pending_total = relation.where(status: %w[pending overdue]).sum(:amount)
    collected_total = relation.where(status: "paid").sum(:amount)
    overdue_total = relation.where(status: "overdue").sum(:amount)
    overdue_count = relation.where(status: "overdue").count
    total = pending_total + collected_total
    {
      pending_total: pending_total,
      collected_total: collected_total,
      overdue_total: overdue_total,
      overdue_count: overdue_count,
      collection_rate: total.zero? ? 0 : ((collected_total.to_f / total) * 100).round(1)
    }
  end

  def payment_type_label
    payment_type.to_s.tr("_", " ").titleize
  end

  def status_label
    return "Overdue" if overdue? && !paid?

    status.to_s.capitalize
  end
end
