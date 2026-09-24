class Visitor < ApplicationRecord
  belongs_to :resident
  has_one :unit, through: :resident
  has_one :user, through: :resident

  validates :name, presence: true, length: { minimum: 2 }
  validates :id_number, presence: true, uniqueness: true
  validates :phone, presence: true, format: { with: /\A\+?\d+\z/, message: "only allows numbers" }
  validates :visit_date, presence: true
  validates :purpose, presence: true, length: { minimum: 5 }
  validates :approved, inclusion: { in: [true, false] }

  scope :ordered, -> { order(visit_date: :desc, created_at: :desc) }
  scope :pending_approval, -> { where(approved: false) }
  scope :approved, -> { where(approved: true) }
  scope :expected_today, -> { where(visit_date: Date.current) }
  scope :on_site, -> { where.not(checked_in_at: nil).where(checked_out_at: nil) }

  def approved?
    approved
  end

  def pending?
    !approved
  end

  def on_site?
    checked_in_at.present? && checked_out_at.nil?
  end

  def approve!
    update!(approved: true, approved_at: Time.current)
  end

  def reject!
    update!(approved: false, approved_at: nil)
  end

  def check_in!
    update!(checked_in_at: Time.current, checked_out_at: nil)
  end

  def check_out!
    update!(checked_out_at: Time.current)
  end

  def status_label
    return "Departed" if checked_out_at.present?
    return "On site" if checked_in_at.present?
    return "Approved" if approved?
    return "Expected" if visit_date && visit_date >= Date.current

    "Pending"
  end
end
