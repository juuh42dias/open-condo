class Ownership < ApplicationRecord
  belongs_to :owner
  belongs_to :unit

  validates :ownership_percentage, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :owner_id, uniqueness: { scope: :unit_id }

  validate :total_ownership_percentage_within_limit

  private

  def total_ownership_percentage_within_limit
    total = Ownership.where(unit: unit).where.not(id: id).sum(:ownership_percentage) + ownership_percentage
    if total > 100
      errors.add(:ownership_percentage, "cannot exceed 100% total ownership for this unit")
    end
  end
end
