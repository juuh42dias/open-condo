class Poll < ApplicationRecord
  STATUSES = %w[open closed].freeze

  belongs_to :building
  belongs_to :user
  has_many :poll_options, dependent: :destroy
  has_many :votes, dependent: :destroy

  accepts_nested_attributes_for :poll_options, allow_destroy: true, reject_if: ->(attrs) { attrs["text"].blank? }

  validates :title, presence: true, length: { minimum: 3 }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validate :at_least_two_options, on: :create

  scope :ordered, -> { order(created_at: :desc) }
  scope :open_polls, -> { where(status: "open").where("closes_at IS NULL OR closes_at > ?", Time.current) }
  scope :for_building, ->(building_id) { where(building_id: building_id) }

  def open?
    status == "open" && (closes_at.nil? || closes_at > Time.current)
  end

  def closed?
    !open?
  end

  def close!
    update!(status: "closed")
  end

  def reopen!
    update!(status: "open", closes_at: nil)
  end

  def voted_by?(user)
    votes.exists?(user_id: user.id)
  end

  def vote_for(user)
    votes.find_by(user_id: user.id)
  end

  def total_votes
    votes.count
  end

  def results
    poll_options.map do |option|
      count = option.votes_count
      pct = total_votes.zero? ? 0 : ((count.to_f / total_votes) * 100).round(1)
      { option: option, count: count, percentage: pct }
    end
  end

  private

  def at_least_two_options
    return if poll_options.reject(&:marked_for_destruction?).size >= 2

    errors.add(:poll_options, "must have at least two options")
  end
end
