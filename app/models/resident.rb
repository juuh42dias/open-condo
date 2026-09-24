class Resident < ApplicationRecord
  belongs_to :user
  belongs_to :unit
  has_many :visitors, dependent: :destroy

  validates :move_in_date, presence: true
  validate :move_out_date_after_move_in_date

  scope :current, -> { where(move_out_date: nil) }

  private

  def move_out_date_after_move_in_date
    return unless move_in_date && move_out_date

    errors.add(:move_out_date, "must be after move in date") if move_out_date <= move_in_date
  end
end
